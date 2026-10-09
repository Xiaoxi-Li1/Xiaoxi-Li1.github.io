#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "uri"
require "yaml"
require "nokogiri"

class PublicationsAudit
  ROOT = File.expand_path("..", __dir__)
  GROUP_COUNTS = { "agents" => 13, "retrieval" => 6, "reward-ml" => 5 }.freeze
  TOTAL = GROUP_COUNTS.values.sum
  SELF_NAME = "Xiaoxi Li"
  TEAM_AUTHORS = {
    "seed2-1" => "ByteDance Seed Team (core contributors including Xiaoxi Li).",
    "agent-world" => "ByteDance Seed Team (core contributors including Xiaoxi Li)."
  }.freeze
  TPAMI_TITLE = "Deep Time-Series Forecasting in 10 Years: A Survey"
  TPAMI_NOTE = "JCR Q1, IF=20.4"
  APPROVED_THRESHOLDS = { "stars_over" => 50, "citations_over" => 20 }.freeze

  attr_reader :checks, :errors, :html_path

  def initialize(html_path = File.join(ROOT, "_site/index.html"))
    @html_path = File.expand_path(html_path)
    @checks = 0
    @errors = []
  end

  # Optional in-memory inputs let regression tests exercise failures without editing the site.
  def run(html: nil, papers: nil, groups: nil, config: nil)
    @checks = 0
    @errors = []
    @papers = papers || JSON.parse(File.read(File.join(ROOT, "_data/publications.json")))
    @groups = groups || YAML.safe_load(File.read(File.join(ROOT, "_data/publication_groups.yml")), aliases: false)
    @config = config || YAML.safe_load(File.read(File.join(ROOT, "_config.yml")), aliases: false)
    return false unless check(@papers.is_a?(Array) && @papers.all? { |item| item.is_a?(Hash) }, "publications.json must contain an array of records")
    return false unless check(@groups.is_a?(Array) && @groups.all? { |item| item.is_a?(Hash) }, "publication_groups.yml must contain an array of groups")
    return false unless check(@config.is_a?(Hash) && @config["publication_metrics"].is_a?(Hash), "_config.yml must define publication_metrics")

    @thresholds = @config["publication_metrics"]
    APPROVED_THRESHOLDS.each do |key, expected|
      value = @thresholds[key]
      check(value.is_a?(Integer) && value >= 0, "publication_metrics.#{key} must be a nonnegative integer")
      check(value == expected, "publication_metrics.#{key} must retain the approved strict > #{expected} threshold")
    end
    origin = @config["visitor_statistics_origin"]
    parsed_origin = uri(origin)
    check(https?(origin) && ["", "/"].include?(parsed_origin.path) && parsed_origin.query.nil? && parsed_origin.fragment.nil?, "visitor_statistics_origin must be a dedicated HTTPS origin, independent of Jekyll site.url")

    check_data
    return false unless errors.empty?

    @document = Nokogiri::HTML(html || File.read(html_path), nil, "UTF-8")
    check_html
    errors.empty?
  rescue JSON::ParserError, Psych::Exception, Errno::ENOENT, Errno::EACCES => e
    check(false, "Cannot read or parse an input: #{e.message.lines.first.to_s.strip}")
    false
  end

  def report(out: $stdout, err: $stderr)
    if errors.empty?
      out.puts "PASS: #{checks} checks across #{TOTAL} publications (13/6/5)."
      out.puts "HTML: #{html_path}"
    else
      err.puts "FAIL: #{errors.length} of #{checks} checks failed."
      errors.each { |message| err.puts "  - #{message}" }
    end
  end

  private

  def check(condition, message)
    @checks += 1
    @errors << message unless condition
    !!condition
  end

  def text(node)
    node ? node.text.gsub(/[[:space:]]+/, " ").strip : ""
  end

  def nonempty?(value)
    value.is_a?(String) && !value.strip.empty?
  end

  def positive_integer?(value)
    value.is_a?(Integer) && value.positive?
  end

  def valid_count?(value)
    (value.is_a?(Integer) || value.is_a?(Float)) && value.finite? && value >= 0
  end

  def parse_star_count(label)
    return nil unless label.is_a?(String)

    match = label.strip.match(/\A((?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?)\s*([kmb])?\z/i)
    return nil unless match

    scale = { "k" => 1_000, "m" => 1_000_000, "b" => 1_000_000_000 }
    count = match[1].delete(",").to_f * scale.fetch(match[2].to_s.downcase, 1)
    count if valid_count?(count)
  end

  def uri(value)
    URI.parse(value) if nonempty?(value)
  rescue URI::InvalidURIError
    nil
  end

  def https?(value)
    parsed = uri(value)
    parsed && parsed.scheme == "https" && nonempty?(parsed.host) && !parsed.userinfo
  end

  def check_data
    ids = @papers.map { |paper| paper["id"] }
    check(ids.length == TOTAL, "Expected #{TOTAL} publication records, found #{ids.length}")
    check(ids.uniq.length == ids.length, "Publication IDs must be unique: #{ids.tally.select { |_, count| count > 1 }.keys.join(', ')}")
    return unless check(ids.all? { |id| id.is_a?(String) && id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/) }, "Publication IDs must be nonempty lowercase slugs")

    @by_id = @papers.to_h { |paper| [paper["id"], paper] }
    group_ids = @groups.map { |group| group["id"] }
    check(group_ids == GROUP_COUNTS.keys, "Groups must occur once, in order: #{GROUP_COUNTS.keys.join(', ')}")
    grouped = []
    @groups.each do |group|
      id = group["id"]
      list = group["papers"]
      next unless check(list.is_a?(Array) && list.all? { |item| item.is_a?(String) }, "Group #{id.inspect}: papers must be an array of IDs")

      grouped.concat(list)
      check(list.length == GROUP_COUNTS[id], "Group #{id}: expected #{GROUP_COUNTS[id].inspect} papers, found #{list.length}")
      check(nonempty?(group["title"]) && nonempty?(group["short_title"]), "Group #{id}: title and short_title are required")
    end
    check(grouped.tally == ids.tally, "Every publication must be grouped exactly once; missing, repeated, or unknown IDs found")
    check(grouped.uniq.length == grouped.length, "A paper is listed in more than one group or repeated within a group")
    check_adjacent("retrieval", "longrefiner", "rag-critic")
    check_adjacent("reward-ml", "causal-rm", "time-series-survey")
    retrieval = @groups.find { |group| group["id"] == "retrieval" }
    check(retrieval && retrieval["title"] == "Retrieval-Augmented LLMs", "Retrieval group title must be exactly Retrieval-Augmented LLMs")
    check(@by_id.dig("hira", "code_url") == "https://github.com/RUC-NLPIR/HiRA", "hira: use the topology-confirmed RUC-NLPIR/HiRA upstream, not the legacy fork")

    overrides = @papers.select { |paper| paper.key?("display_authors") }.map { |paper| paper["id"] }
    check(overrides.sort == TEAM_AUTHORS.keys.sort, "Only Seed2.1 and Agent-World may override display_authors")
    TEAM_AUTHORS.each do |id, expected|
      check(@by_id.dig(id, "display_authors") == expected, "#{id}: display_authors must exactly equal #{expected.inspect}")
    end
    tpami = @by_id["time-series-survey"] || {}
    check(tpami["title"] == TPAMI_TITLE, "time-series-survey: keep the approved TPAMI title #{TPAMI_TITLE.inspect}")
    check(tpami["venue"] == "IEEE TPAMI 2026", "time-series-survey: venue must be IEEE TPAMI 2026")
    check(tpami["venue_note"] == TPAMI_NOTE, "time-series-survey: venue_note must be #{TPAMI_NOTE.inspect}")

    @papers.each { |paper| check_paper_data(paper) }
  end

  def check_adjacent(group_id, before, after)
    group = @groups.find { |item| item["id"] == group_id }
    list = group && group["papers"].is_a?(Array) ? group["papers"] : []
    position = list.index(before)
    check(position && list[position + 1] == after, "Group #{group_id}: #{after} must immediately follow #{before}")
  end

  def check_paper_data(paper)
    id = paper["id"]
    %w[title venue summary figure_caption figure_alt].each do |key|
      check(nonempty?(paper[key]), "#{id}: #{key} must be nonempty")
    end
    authors = paper["authors"]
    valid_authors = check(authors.is_a?(Array) && !authors.empty? && authors.all? { |name| nonempty?(name) }, "#{id}: authors must contain the complete ordered author names")
    if valid_authors && !TEAM_AUTHORS.key?(id)
      check(authors.count(SELF_NAME) == 1, "#{id}: authors must contain Xiaoxi Li exactly once")
    end
    %w[publication_url pdf_url].each do |key|
      check(https?(paper[key]), "#{id}: #{key} must be an absolute HTTPS URL")
    end
    paper.each do |key, value|
      next unless (key.end_with?("_url") || key == "stars_image") && !%w[publication_url pdf_url].include?(key)
      next if value.nil?

      check(https?(value), "#{id}: #{key} must be an absolute HTTPS URL")
    end
    pdf = uri(paper["pdf_url"])
    check(pdf && (pdf.path.downcase.end_with?(".pdf") || pdf.path.match?(%r{/(?:pdf|epdf)/})), "#{id}: pdf_url must point to a PDF resource, not an abstract page")
    check(positive_integer?(paper["figure_page"]), "#{id}: figure_page must be a positive, one-based PDF page number")
    label = paper["figure_label"]
    check(label.is_a?(String) && label.match?(/\A(?:Figure|Fig\.)\s+[1-9]\d*[a-z]?\z/i), "#{id}: figure_label must identify an actual numbered PDF figure")
    %w[image_width image_height].each do |key|
      check(positive_integer?(paper[key]), "#{id}: #{key} must be a positive integer")
    end
    { "image" => "#{id}.webp", "image_full" => "#{id}-full.webp" }.each do |key, filename|
      expected = "/images/publications/#{filename}"
      next unless check(paper[key] == expected, "#{id}: #{key} must be #{expected}")

      path = File.join(ROOT, expected.delete_prefix("/"))
      check(File.file?(path) && File.size?(path), "#{id}: missing or empty #{key} file #{path}")
    end
    check(nonempty?(paper["scholar_id"]), "#{id}: retain scholar_id so hidden citations can update later")
    count = paper["citations"]
    check(paper.key?("citations") && (count.nil? || (count.is_a?(Integer) && count >= 0)), "#{id}: citations must be a nonnegative integer or null when unknown")
    check(https?(paper["citation_url"]), "#{id}: citation_url must be HTTPS")
    check(!paper.key?("stars_image"), "#{id}: replace legacy stars_image with text metrics backed by stars_url")
    code = uri(paper["code_url"])
    if code&.host == "github.com"
      check(nonempty?(paper["stars_url"]), "#{id}: retain a Stars source even for a low or unknown snapshot")
    end
    return unless paper["stars_url"]

    source = uri(paper["stars_url"])
    check(https?(paper["stars_url"]) && source&.host == "img.shields.io" && source.path.match?(%r{\A/github/stars/[^/]+/[^/]+\.json\z}), "#{id}: stars_url must be a Shields GitHub-stars JSON endpoint")
    if code&.host == "github.com" && source
      repo = code.path.delete_suffix("/").delete_suffix(".git")
      check(source.path.casecmp?("/github/stars#{repo}.json"), "#{id}: Stars source must refer to the same repository as Code")
    end
    stars = paper["stars_count"]
    check(paper.key?("stars_count") && (stars.nil? || valid_count?(stars)), "#{id}: stars_count must be a finite nonnegative number or null")
    if stars.nil?
      check(paper["stars_label"].nil? || paper["stars_label"].is_a?(String), "#{id}: unknown Stars label must be text or null")
    else
      parsed = parse_star_count(paper["stars_label"])
      check(parsed && valid_count?(stars) && (parsed - stars).abs <= [parsed.abs, 1].max * 1e-9, "#{id}: stars_count must match its original compact stars_label")
      check(nonempty?(paper["stars_as_of"]), "#{id}: a known Stars snapshot needs stars_as_of")
    end
  end

  def check_html
    all_ids = @document.css("[id]").map { |node| node["id"] }
    duplicates = all_ids.tally.select { |_, count| count > 1 }.keys
    check(duplicates.empty?, "Rendered HTML contains duplicate DOM IDs: #{duplicates.join(', ')}")
    footer = @document.at_css("#footer[data-site-origin]")
    check(footer && footer["data-site-origin"] == @config["visitor_statistics_origin"], "Footer data-site-origin must equal configured visitor_statistics_origin, not a rewritten site.url")
    check(text(footer&.at_css("#busuanzi_container_site_pv")) == "Total Visitors:", "Footer must label the PV counter Total Visitors")
    check(footer && footer.css("[data-traffic-value]").map { |node| node["id"] } == ["busuanzi_value_site_pv"], "Only the PV counter may be active in the footer")
    check(@document.css("#busuanzi_container_site_uv, #busuanzi_value_site_uv").empty?, "Unique Visitors must stay commented out, not in the active DOM")
    section = @document.at_css("section#publications.publications")
    return unless check(section, "Rendered HTML is missing section#publications.publications")

    cards = @document.css(".publication")
    expected_ids = @groups.flat_map { |group| group["papers"] }.map { |id| "paper-#{id}" }
    check(cards.length == TOTAL, "Rendered HTML must have #{TOTAL} .publication cards, found #{cards.length}")
    check(cards.map { |card| card["id"] }.tally == expected_ids.tally, "Rendered publication IDs do not match the data exactly once")
    check(section.css(".publication").map { |card| card["id"] } == expected_ids, "Rendered paper order or section placement differs from publication_groups.yml")
    check(section.css(".publication-group").length == GROUP_COUNTS.length, "Rendered HTML must contain exactly three publication groups")
    check_navigation(section)
    @groups.each do |group|
      node = section.at_css("section.publication-group##{group['id']}")
      next unless check(node, "Rendered group #{group['id']} is missing")

      check(text(node.at_css("h2")) == group["title"], "Rendered heading for #{group['id']} differs from its data")
      check(node.css(".publication").map { |card| card["id"] } == group["papers"].map { |id| "paper-#{id}" }, "Rendered group #{group['id']} has missing, reordered, or extra papers")
    end
    @papers.each do |paper|
      found = section.css("#paper-#{paper['id']}.publication")
      next unless check(found.length == 1, "#{paper['id']}: expected exactly one rendered card")

      check_paper_html(paper, found.first)
    end
    section.css("a[href]").each do |link|
      next if link["class"].to_s.split.include?("publication__figure")
      next if local_anchor?(link["href"])

      check(https?(link["href"]), "Rendered publication link must use HTTPS: #{link['href'].inspect}")
    end
    dialog = @document.at_css("dialog#publication-figure")
    if check(dialog, "Missing native dialog#publication-figure for full-size figures")
      check(dialog["aria-labelledby"] == "figure-title" && dialog.at_css("#figure-title"), "Figure dialog must reference its accessible title")
      check(dialog.at_css("img.figure-dialog__image"), "Figure dialog is missing its full-size image")
      check(dialog.at_css("button.figure-dialog__close[type='button'][aria-label]"), "Figure dialog must have a named native close button")
      check(dialog.at_css("a#figure-source"), "Figure dialog must retain the original PDF source link")
    end
  end

  def local_anchor?(value)
    parsed = uri(value)
    parsed && parsed.scheme.nil? && parsed.host.nil? && ["", "/"].include?(parsed.path) && nonempty?(parsed.fragment)
  end

  def check_anchor(link, allowed_ids, description)
    parsed = uri(link["href"])
    check(local_anchor?(link["href"]) && allowed_ids.include?(parsed&.fragment), "#{description}: link must target its local publication section")
    check(link["target"] == "_self", "#{description}: link must use target=_self, despite the global base target")
    target = parsed&.fragment
    check(target && @document.css("[id]").any? { |node| node["id"] == target }, "#{description}: target #{target.inspect} does not exist")
  end

  def check_navigation(section)
    nav = section.at_css("nav.publications__nav")
    if check(nav, "Missing publications group navigation")
      @groups.each do |group|
        matches = nav.css("a[href]").select { |link| uri(link["href"])&.fragment == group["id"] }
        next unless check(matches.length == 1, "Group navigation must link to #{group['id']} exactly once")

        check_anchor(matches.first, [group["id"]], "Group navigation #{group['id']}")
      end
    end
    links = @document.css(".masthead a").select { |link| text(link) == "Publications" }
    check(!links.empty?, "Top navigation is missing the Publications link")
    links.each { |link| check_anchor(link, %w[publications -publications -selected-work], "Top Publications navigation") }
  end

  def check_paper_html(paper, card)
    id = paper["id"]
    check(card.name == "article", "#{id}: publication card must be an article")
    check(card["aria-labelledby"] == "title-#{id}", "#{id}: card must reference its own title")
    title = card.at_css("h3.publication__title#title-#{id} a")
    check(text(title) == paper["title"] && title&.[]("href") == paper["publication_url"], "#{id}: rendered title or publication link differs from data")
    figure = card.at_css("a.publication__figure")
    if check(figure, "#{id}: missing figure link")
      check(figure["href"] == paper["image_full"], "#{id}: figure must link to its own full-size image")
      check(figure["data-figure-source"] == "#{paper['pdf_url']}#page=#{paper['figure_page']}", "#{id}: enlarged figure must link to the correct PDF page")
      check(figure["data-figure-title"] == paper["title"], "#{id}: figure dialog title differs from data")
      caption = figure["data-figure-caption"].to_s
      expected_caption = "#{paper['figure_label']} \u00b7 PDF page #{paper['figure_page']}"
      check(caption == expected_caption, "#{id}: figure link must carry its exact figure number and PDF page")
      images = figure.css("img")
      if check(images.length == 1, "#{id}: figure link must contain exactly one thumbnail")
        image = images.first
        check(image["src"] == paper["image"], "#{id}: thumbnail source differs from data")
        check(image["alt"] == paper["figure_alt"], "#{id}: thumbnail alt text differs from data")
        check(image["width"] == paper["image_width"].to_s && image["height"] == paper["image_height"].to_s, "#{id}: thumbnail width/height differ from data")
      end
    end
    card.css("img").each do |image|
      check(nonempty?(image["alt"]), "#{id}: every publication image needs nonempty alt text")
      check(%w[width height].all? { |key| image[key].to_s.match?(/\A[1-9]\d*\z/) }, "#{id}: every publication image needs positive width and height")
      check(image["loading"] == "lazy", "#{id}: every publication thumbnail or badge must use loading=lazy")
    end
    check(text(card.at_css(".venue-name")) == paper["venue"], "#{id}: rendered venue differs from data")
    if paper["venue_note"]
      check(text(card.at_css(".venue-note")) == paper["venue_note"], "#{id}: rendered journal note differs from data")
    end
    paper_links = card.css(".publication__links a[href]").map { |link| link["href"] }
    %w[pdf_url code_url project_url arxiv_url].each do |key|
      check(paper_links.include?(paper[key]), "#{id}: rendered links omit #{key}") if paper[key]
    end
    { "Paper" => paper["pdf_url"], "Code" => paper["code_url"] }.each do |label, url|
      next unless url

      links = card.css(".publication__links a[href]").select { |link| text(link) == label && link["href"] == url }
      visible = links.length == 1 && !links.first.key?("hidden") && links.first.ancestors.none? { |node| node.key?("hidden") }
      check(visible, "#{id}: #{label} must remain present and visible regardless of metric thresholds")
    end
    check_metrics(paper, card)
    check_authors(paper, card.at_css(".publication__authors"))
  end

  def check_metrics(paper, card)
    id = paper["id"]
    citations = card.css("[data-citation-metric]")
    if check(citations.length == 1, "#{id}: keep one citation metric in the DOM, even when low or unknown")
      metric = citations.first
      threshold = @thresholds["citations_over"]
      check(metric["data-citation-threshold"] == threshold.to_s, "#{id}: rendered citation threshold differs from _config.yml")
      visible = valid_count?(paper["citations"]) && paper["citations"] > threshold
      check(metric.key?("hidden") == !visible, "#{id}: citation snapshot must be visible only when strictly > #{threshold}; unknown stays hidden")
      values = metric.css("span[data-scholar-id]")
      check(values.length == 1 && values.first["data-scholar-id"] == paper["scholar_id"] && text(values.first) == paper["citations"].to_s, "#{id}: citation counter must retain its data ID and snapshot")
      check(metric["href"] == paper["citation_url"], "#{id}: citation metric link differs from data")
    end
    stars = card.css("[data-star-metric]")
    unless paper["stars_url"]
      check(stars.empty?, "#{id}: do not render a Stars metric without a source")
      return
    end
    return unless check(stars.length == 1, "#{id}: keep one Stars metric in the DOM, even when low or unknown")

    metric = stars.first
    threshold = @thresholds["stars_over"]
    check(metric["data-star-source"] == paper["stars_url"], "#{id}: rendered Stars source differs from data")
    check(metric["data-star-threshold"] == threshold.to_s, "#{id}: rendered Stars threshold differs from _config.yml")
    visible = valid_count?(paper["stars_count"]) && paper["stars_count"] > threshold
    check(metric.key?("hidden") == !visible, "#{id}: Stars snapshot must be visible only when strictly > #{threshold}; unknown stays hidden")
    values = metric.xpath("./span[@data-github-stars]")
    check(values.length == 1 && text(values.first) == paper["stars_label"].to_s, "#{id}: Stars must preserve the original compact snapshot label")
    check(metric.css("img").empty?, "#{id}: Stars must be text, not an unreadable badge image")
    check(metric["href"] == paper["code_url"], "#{id}: Stars metric must link to its Code repository")
  end

  def check_authors(paper, wrapper)
    id = paper["id"]
    return unless check(wrapper, "#{id}: author section is missing")

    if TEAM_AUTHORS.key?(id)
      check(text(wrapper) == TEAM_AUTHORS[id], "#{id}: rendered team authors must match the approved wording exactly")
      check(wrapper.css("details, summary, .author-full").empty?, "#{id}: team override must not grow an extra author list or toggle")
      check(wrapper.css("strong").map { |node| text(node) } == [SELF_NAME], "#{id}: team authors must highlight Xiaoxi Li exactly once")
      return
    end
    authors = paper["authors"]
    self_index = authors.index(SELF_NAME)
    if authors.length > 5 || self_index > 2
      details = wrapper.css("details.author-details")
      return unless check(details.length == 1, "#{id}: long/late author lists must use one native details.author-details")

      detail = details.first
      summaries = detail.xpath("./summary")
      check(summaries.length == 1 && detail.element_children.first == summaries.first, "#{id}: native summary must be the first details child")
      check(!detail.key?("open"), "#{id}: full author list must be collapsed initially")
      full = detail.css(".author-full")
      check(full.length == 1 && text(full.first) == authors.join(", "), "#{id}: full rendered author list differs from the complete ordered data")
      preview = summaries.first&.at_css(".author-preview")
      check(preview && text(preview).include?(SELF_NAME), "#{id}: Xiaoxi Li must be visible in the collapsed summary")
      check(preview && preview.css("strong").map { |node| text(node) } == [SELF_NAME], "#{id}: collapsed summary must highlight Xiaoxi Li exactly once")
      expected = if self_index > 2
                   prefix = ["...", SELF_NAME]
                   prefix << "..." if self_index + 1 < authors.length - 2
                   prefix + authors.last(2).reject { |name| name == SELF_NAME }
                 else
                   authors.first(3) + ["..."] + authors.last(2)
                 end
      check(text(preview) == expected.join(", "), "#{id}: collapsed author summary has incorrect names, order, or ellipses")
      check(text(preview).start_with?("..., #{SELF_NAME}"), "#{id}: late-author summary must begin with ..., Xiaoxi Li") if self_index > 2
    else
      check(wrapper.css("details, summary").empty?, "#{id}: short author lists should not introduce an unnecessary toggle")
      check(text(wrapper) == authors.join(", "), "#{id}: short rendered author list differs from data")
      check(wrapper.css("strong").map { |node| text(node) } == [SELF_NAME], "#{id}: short author list must highlight Xiaoxi Li exactly once")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV.length > 1 || (ARGV.first&.start_with?("-") && !%w[-h --help].include?(ARGV.first))
    warn "Usage: bundle exec ruby docs/check_publications.rb [built/index.html]"
    exit 2
  end
  if %w[-h --help].include?(ARGV.first)
    puts "Usage: bundle exec ruby docs/check_publications.rb [built/index.html]"
    puts "Defaults to _site/index.html; checks local data/assets and rendered Publications only."
    exit 0
  end
  audit = ARGV.empty? ? PublicationsAudit.new : PublicationsAudit.new(ARGV.first)
  success = audit.run
  audit.report
  exit(success ? 0 : 1)
end
