#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "date"
require "uri"
require "yaml"
require "nokogiri"

class PublicationsAudit
  ROOT = File.expand_path("..", __dir__)
  GROUP_COUNTS = { "agents" => 13, "retrieval" => 6, "reward-ml" => 5 }.freeze
  GROUP_NAV_TITLES = { "agents" => "LLM/VLM Agents", "retrieval" => "RAG & LLMs", "reward-ml" => "Reward & ML" }.freeze
  TOTAL = GROUP_COUNTS.values.sum
  SELF_NAME = "Xiaoxi Li"
  ABOUT_RESEARCH_COPY = "I'm currently a research intern at ByteDance Seed, focusing on RL scaling for general agents, particularly co-work agent RL and Seed agent RL big runs. " \
                        "I previously interned at Xiaohongshu Inc (the first RedStar program). " \
                        "I have published 30+ papers (8 as first author) in leading journals and conferences, including TPAMI, NeurIPS, ICML, ICLR, ACL, EMNLP, SIGIR, etc."
  SELECTED_AWARDS = [
    "2026: BAAI InnoVibe Most Notable Academic Rising Star (\u9752\u6e90InnoVibe\u6700\u53d7\u77a9\u76ee\u5b66\u672f\u65b0\u661f\uff0c\u5168\u740325\u4eba).",
    "2026: CIE-Tencent Hunyuan PhD Research Incentive Program (\u4e2d\u56fd\u7535\u5b50\u5b66\u4f1a-\u817e\u8baf\u6df7\u5143\u535a\u58eb\u751f\u79d1\u7814\u6fc0\u52b1\u8ba1\u5212\uff0c10w/\u4eba).",
    "2026: Young Talent Development Program for Doctoral Students, CAST (\u4e2d\u56fd\u79d1\u534f\u9752\u5e74\u4eba\u624d\u57f9\u80b2\u5de5\u7a0b\u535a\u58eb\u751f\u4e13\u9879).",
    "2026: National Scholarship for Ph.D. Students, Renmin University of China (\u4e2d\u56fd\u4eba\u6c11\u5927\u5b66\u535a\u58eb\u751f\u56fd\u5bb6\u5956\u5b66\u91d1; Top 1%)."
  ].freeze
  TEAM_AUTHORS = {
    "seed2-1" => "ByteDance Seed Team (core contributors including Xiaoxi Li).",
    "agent-world" => "ByteDance Seed Team (core contributors including Xiaoxi Li)."
  }.freeze
  TPAMI_TITLE = "Deep Time-Series Forecasting in 10 Years: A Survey"
  TPAMI_NOTE = "JCR Q1, IF=20.4"
  APPROVED_THRESHOLDS = { "stars_over" => 50, "citations_over" => 20 }.freeze
  APPROVED_EMPHASIS_MINIMUMS = { "stars_emphasis_min" => 1000, "citations_emphasis_min" => 100 }.freeze
  MEDIA_LABELS = ["REDtech", "RUC", "\u673a\u5668\u4e4b\u5fc3", "\u91cf\u5b50\u4f4d", "\u65b0\u667a\u5143"].freeze
  APPROVED_MEDIA_LINKS = {
    "deepagent" => [
      ["REDtech", "https://mp.weixin.qq.com/s/ooU--PPm1dEUWSeJYBhrDA"],
      ["RUC", "https://mp.weixin.qq.com/s/e4dwMY6S8WpbQk9IUEPtHw"]
    ],
    "webthinker" => [["\u673a\u5668\u4e4b\u5fc3", "https://mp.weixin.qq.com/s/B-X0WTAiV-FNbt0nm2O1Lw"]],
    "search-o1" => [
      ["\u91cf\u5b50\u4f4d", "https://mp.weixin.qq.com/s/J_n5cn_Zp4lRs8ESqFEFmg"],
      ["\u65b0\u667a\u5143", "https://mp.weixin.qq.com/s/ytAqw5TNF2JD7UXS-S17gg"]
    ],
    "aepo" => [["\u673a\u5668\u4e4b\u5fc3", "https://mp.weixin.qq.com/s/mL3CTNonZVoLWnQVfK7KAw"]],
    "hypothesis-tree" => [["\u91cf\u5b50\u4f4d", "https://mp.weixin.qq.com/s/51ojDAqmFrRG08P2IhcXSA"]],
    "genir-survey" => [["RUC", "https://mp.weixin.qq.com/s/iFilKVctb-fiMhYe_Gjuzw"]]
  }.freeze
  CCF_RANKS = {
    "deepagent" => "A", "webthinker" => "A", "search-o1" => "B",
    "hira" => "A", "tool-star" => "A", "verigraph" => "A", "aepo" => "A",
    "retrollm" => "A", "longrefiner" => "A", "rag-critic" => "A",
    "corpuslm" => "A", "unigen" => "A", "genir-survey" => "A",
    "implicit-rm" => "A", "time-series-survey" => "A", "distdf" => "A"
  }.freeze
  SEED_BANNER = {
    "figure_source_type" => "project-banner",
    "figure_source_url" => "https://seed.bytedance.com/en/seed2_1",
    "figure_label" => "Project banner",
    "image_width" => 600, "image_height" => 240,
    "image_full_width" => 1409, "image_full_height" => 564,
    "image_version" => "d98af11ba52b",
    "source_image_sha256" => "d98af11ba52b86d1274502f4d279a9e4ca4f9bda431837969ec2e54c6b3a370e"
  }.freeze
  PROFILE_METRICS_SOURCE = "https://raw.githubusercontent.com/Xiaoxi-Li1/Xiaoxi-Li1.github.io/google-scholar-stats/gs_data.json"
  PROFILE_METRICS = {
    "citedby" => ["citations", "citedby"],
    "github_stars" => ["GitHub stars", "github_stars_k"]
  }.freeze
  VISITOR_BADGE_SOURCE = "https://visitor-badge.laobi.icu/badge?page_id=https%3A%2F%2Fxiaoxi-li1.github.io%2F&left_text=Total%20Visitors&left_color=%23000000&right_color=%23000000"
  ASSET_ENTRYPOINTS = {
    "/assets/css/main.css" => ["link[rel='stylesheet'][href]", "href", nil],
    "/assets/js/main.min.js" => ["script[src]", "src", false],
    "/assets/js/author-contact.js" => ["script[src]", "src", true],
    "/assets/js/publication-metrics.js" => ["script[src]", "src", true],
    "/assets/js/publications.js" => ["script[src]", "src", true],
    "/assets/js/site-traffic.js" => ["script[src]", "src", true]
  }.freeze

  attr_reader :checks, :errors, :html_path

  def initialize(html_path = File.join(ROOT, "_site/index.html"))
    @html_path = File.expand_path(html_path)
    @checks = 0
    @errors = []
  end

  # Optional in-memory inputs let regression tests exercise failures without editing the site.
  def run(html: nil, papers: nil, groups: nil, config: nil, profile_metrics: nil)
    @checks = 0
    @errors = []
    @papers = papers || JSON.parse(File.read(File.join(ROOT, "_data/publications.json")))
    @groups = groups || YAML.safe_load(File.read(File.join(ROOT, "_data/publication_groups.yml")), aliases: false)
    @config = config || YAML.safe_load(File.read(File.join(ROOT, "_config.yml")), aliases: false)
    @profile_metrics = profile_metrics || JSON.parse(File.read(File.join(ROOT, "_data/profile_metrics.json")))
    return false unless check(@papers.is_a?(Array) && @papers.all? { |item| item.is_a?(Hash) }, "publications.json must contain an array of records")
    return false unless check(@groups.is_a?(Array) && @groups.all? { |item| item.is_a?(Hash) }, "publication_groups.yml must contain an array of groups")
    return false unless check(@config.is_a?(Hash) && @config["publication_metrics"].is_a?(Hash), "_config.yml must define publication_metrics")
    return false unless check(@profile_metrics.is_a?(Hash), "profile_metrics.json must contain an object of aggregate snapshots")

    @thresholds = @config["publication_metrics"]
    APPROVED_THRESHOLDS.each do |key, expected|
      value = @thresholds[key]
      check(value.is_a?(Integer) && value >= 0, "publication_metrics.#{key} must be a nonnegative integer")
      check(value == expected, "publication_metrics.#{key} must retain the approved strict > #{expected} threshold")
    end
    APPROVED_EMPHASIS_MINIMUMS.each do |key, expected|
      value = @thresholds[key]
      check(value.is_a?(Integer) && value > 0, "publication_metrics.#{key} must be a positive integer")
      check(value == expected, "publication_metrics.#{key} must retain the approved >= #{expected} emphasis minimum")
    end
    origin = @config["visitor_statistics_origin"]
    parsed_origin = uri(origin)
    check(https?(origin) && ["", "/"].include?(parsed_origin.path) && parsed_origin.query.nil? && parsed_origin.fragment.nil?, "visitor_statistics_origin must be a dedicated HTTPS origin, independent of Jekyll site.url")

    check_data
    check_profile_metrics_data
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

  def statically_visible?(node)
    node && [node, *node.ancestors].none? do |ancestor|
      closed_details = ancestor.name == "details" && !ancestor.key?("open")
      summary = ancestor.element_children.find { |child| child.name == "summary" } if closed_details
      directly_hidden?(ancestor) || (closed_details && node != summary && !node.ancestors.include?(summary))
    end
  end

  def directly_hidden?(node, allow_hidden_attribute: false)
    node.name == "template" || (!allow_hidden_attribute && node.key?("hidden")) || node["aria-hidden"] == "true" ||
      node["style"].to_s.match?(/(?:\A|;)\s*(?:display\s*:\s*none|visibility\s*:\s*hidden)\b/i)
  end

  def overrides_hidden?(node)
    displays = node["style"].to_s.scan(/(?:\A|;)\s*display\s*:\s*([^;]*)/i).flatten
    displays.any? { |value| !value.strip.match?(/\Anone(?:\s*!important)?\z/i) }
  end

  def iso_date(value)
    Date.iso8601(value) if value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
  rescue Date::Error
    nil
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
      check(group["short_title"] == GROUP_NAV_TITLES[id], "Group #{id}: retain the approved compact navigation label")
    end
    check(grouped.tally == ids.tally, "Every publication must be grouped exactly once; missing, repeated, or unknown IDs found")
    check(grouped.uniq.length == grouped.length, "A paper is listed in more than one group or repeated within a group")
    check_adjacent("agents", "agent-world", "hypothesis-tree")
    check_adjacent("agents", "hypothesis-tree", "verigraph")
    check_adjacent("agents", "verigraph", "aepo")
    check_adjacent("agents", "aepo", "tool-star")
    check_adjacent("retrieval", "retrollm", "corpuslm")
    check_adjacent("retrieval", "corpuslm", "unigen")
    check_adjacent("retrieval", "longrefiner", "rag-critic")
    check_adjacent("reward-ml", "implicit-rm", "distdf")
    retrieval = @groups.find { |group| group["id"] == "retrieval" }
    check(retrieval && retrieval["title"] == "Retrieval-Augmented LLMs", "Retrieval group title must be exactly Retrieval-Augmented LLMs")
    check(retrieval && retrieval["papers"].is_a?(Array) && retrieval["papers"].first == "genir-survey", "Retrieval group must begin with the Generative Information Retrieval survey")
    reward_ml = @groups.find { |group| group["id"] == "reward-ml" }
    check(reward_ml && reward_ml["papers"].is_a?(Array) && reward_ml["papers"].first == "time-series-survey", "Reward/ML group must begin with the TPAMI time-series survey")
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
    if CCF_RANKS.key?(id)
      check(paper["ccf_rank"] == CCF_RANKS[id], "#{id}: ccf_rank must be #{CCF_RANKS[id]} under the approved 2026 CCF catalog")
    else
      check(!paper.key?("ccf_rank"), "#{id}: preprints and technical reports must not carry a ccf_rank field")
    end
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
    check_media_data(paper)
    pdf = uri(paper["pdf_url"])
    check(pdf && (pdf.path.downcase.end_with?(".pdf") || pdf.path.match?(%r{/(?:pdf|epdf)/})), "#{id}: pdf_url must point to a PDF resource, not an abstract page")
    check_figure_data(paper)
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

  def check_figure_data(paper)
    id = paper["id"]
    if id == "seed2-1"
      SEED_BANNER.each do |key, expected|
        check(paper[key] == expected, "#{id}: #{key} must match the approved project banner (#{expected.inspect})")
      end
      %w[figure_page figure_crop_pdf_points source_pdf_sha256].each do |key|
        check(!paper.key?(key), "#{id}: project banner must not retain PDF figure metadata #{key}")
      end
    else
      check(!paper.key?("figure_source_type") || paper["figure_source_type"] == "pdf", "#{id}: only seed2-1 may use a non-PDF figure source")
      check(positive_integer?(paper["figure_page"]), "#{id}: figure_page must be a positive, one-based PDF page number")
      label = paper["figure_label"]
      check(label.is_a?(String) && label.match?(/\A(?:Figure|Fig\.)\s+[1-9]\d*[a-z]?\z/i), "#{id}: figure_label must identify an actual numbered PDF figure")
    end
    %w[image_width image_height].each do |key|
      check(positive_integer?(paper[key]), "#{id}: #{key} must be a positive integer")
    end
    %w[image_full_width image_full_height].each do |key|
      check(positive_integer?(paper[key]), "#{id}: #{key} must be a positive integer when provided") if paper.key?(key)
    end
    if paper.key?("image_version")
      version = paper["image_version"]
      check(nonempty?(version) && version.match?(/\A[A-Za-z0-9._-]+\z/), "#{id}: image_version must be a nonempty URL-safe version")
    end
  end

  def check_html
    all_ids = @document.css("[id]").map { |node| node["id"] }
    duplicates = all_ids.tally.select { |_, count| count > 1 }.keys
    check(duplicates.empty?, "Rendered HTML contains duplicate DOM IDs: #{duplicates.join(', ')}")
    check_footer
    check_profile_metrics_html
    check_author_contacts
    check_research_experiences
    check_section_headings
    check_selected_awards
    check_news
    section = @document.at_css("section#publications.publications")
    return unless check(section, "Rendered HTML is missing section#publications.publications")

    cards = @document.css(".publication")
    expected_ids = @groups.flat_map { |group| group["papers"] }.map { |id| "paper-#{id}" }
    check(cards.length == TOTAL, "Rendered HTML must have #{TOTAL} .publication cards, found #{cards.length}")
    check(cards.map { |card| card["id"] }.tally == expected_ids.tally, "Rendered publication IDs do not match the data exactly once")
    check(section.css(".publication").map { |card| card["id"] } == expected_ids, "Rendered paper order or section placement differs from publication_groups.yml")
    check(section.css(".publication-group").length == GROUP_COUNTS.length, "Rendered HTML must contain exactly three publication groups")
    check(section.css(".venue-rank, [data-ccf-rank]").length == CCF_RANKS.length, "Rendered HTML must contain exactly #{CCF_RANKS.length} CCF labels for accepted papers")
    check_navigation(section)
    check_asset_versions
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
      check(dialog.at_css("a#figure-source"), "Figure dialog must retain the original PDF or project-page source link")
    end
  end

  def check_profile_metrics_data
    expected_keys = %w[source_url source_updated citedby github_stars github_stars_k]
    check(@profile_metrics.keys.sort == expected_keys.sort, "Profile snapshots must contain only total citations, total Stars, and their source provenance; omit first-author fields")
    check(@profile_metrics["source_url"] == PROFILE_METRICS_SOURCE, "Profile metrics must retain the existing Scholar JSON source URL")
    check(nonempty?(@profile_metrics["source_updated"]), "Profile metrics must retain the source snapshot timestamp")
    PROFILE_METRICS.each do |key, (_, display_key)|
      count = @profile_metrics[key]
      valid = check(count.is_a?(Integer) && count.between?(0, 9_007_199_254_740_991), "Profile #{key}: snapshot must be a nonnegative safe integer")
      next if key == display_key || !valid

      # Match the crawler's one-decimal k labels without floating-point rounding.
      tenths = (count + 50) / 100
      expected = "#{tenths / 10}.#{tenths % 10}k"
      check(@profile_metrics[display_key] == expected, "Profile #{display_key}: snapshot label must match ROUND_HALF_UP to one k decimal (#{expected})")
    end
  end

  def check_profile_metrics_html
    wrappers = @document.css(".profile-metrics")
    return unless check(wrappers.length == 1 && wrappers.first.name == "span", "Render one inline span.profile-metrics, not a separate metrics block")

    wrapper = wrappers.first
    paragraph = wrapper.parent
    paragraph_text = text(paragraph).tr("\u2019", "'")
    expected_sentence = "My research and open-source projects have received #{@profile_metrics['citedby']} citations and #{@profile_metrics['github_stars_k']} GitHub stars."
    check(paragraph.name == "p" && paragraph_text == "#{ABOUT_RESEARCH_COPY} #{expected_sentence}", "About me must retain the approved Seed RL role, first RedStar program, publication count, venues, and inline totals")
    check(paragraph.css("strong").map { |node| text(node) } == ["RL scaling for general agents"], "About me must bold only the requested RL scaling phrase, not the surrounding text or aggregate metrics")
    check(text(wrapper) == expected_sentence && paragraph_text.end_with?(expected_sentence), "Profile totals must form the approved sentence at the end of the existing About me paragraph")
    check(wrapper.css("br, hr, div, p").empty?, "Profile sentence must not force a separate line or block")
    links = wrapper.css("a")
    check(links.map { |link| link["data-profile-metric"] } == PROFILE_METRICS.keys, "Profile sentence must render only total citations and project Stars, in order")
    check(@document.css("[data-profile-metric]").length == PROFILE_METRICS.length, "Only two aggregate profile metric hooks may be present; omit first-author metrics")
    check(wrapper.css("img").empty?, "Profile metrics must be text links, not badge images")
    check(wrapper.css("[data-citation-metric], [data-star-metric], [data-citation-threshold], [data-star-threshold]").empty?, "Aggregate profile totals must not reuse per-paper threshold hooks")
    PROFILE_METRICS.each do |key, (label, display_key)|
      matches = links.select { |link| link["data-profile-metric"] == key }
      next unless check(matches.length == 1, "Profile #{key}: expected one text link")

      link = matches.first
      compact = key != display_key
      expected_href = compact ? "https://github.com/sunnynexus" : @config.dig("author", "googlescholar")
      check(https?(expected_href) && link["href"] == expected_href, "Profile #{key}: link must target its configured Scholar or GitHub profile")
      values = link.css("span[data-profile-value]")
      if check(values.length == 1, "Profile #{key}: retain one span[data-profile-value] for live updates")
        check(text(values.first) == @profile_metrics[display_key].to_s, "Profile #{key}: displayed value must match the aggregate snapshot")
        check(statically_visible?(link) && statically_visible?(values.first), "Profile #{key}: aggregate totals must stay visible independently of per-paper thresholds")
      end
      check(text(link) == "#{@profile_metrics[display_key]} #{label}", "Profile #{key}: text must put the snapshot value before its inline label")
      check(link.key?("data-compact-count") == compact, "Profile #{key}: only aggregate Stars use compact-count formatting")
      icons = link.css("i.fab.fa-github")
      check(compact ? icons.length == 1 && icons.first["aria-hidden"] == "true" : icons.empty?, "Profile #{key}: only Stars should carry one decorative GitHub icon")
      scholar_icons = link.css("svg")
      if compact
        check(scholar_icons.empty?, "Profile Stars must retain the GitHub icon, not a Scholar SVG")
      elsif check(scholar_icons.length == 1, "Profile citations must contain one inline Google Scholar SVG")
        icon = scholar_icons.first
        check(icon["class"].to_s.split.include?("profile-metrics__scholar-icon") && icon["aria-hidden"] == "true" && icon["focusable"] == "false", "Google Scholar SVG must use its approved class and decorative accessibility attributes")
        check((icon["viewBox"] || icon["viewbox"]) == "0 0 24 24" && icon.css("path[d]").any? { |path| nonempty?(path["d"]) }, "Google Scholar SVG must retain its 24x24 viewBox and inline path")
        check(link.element_children.first == icon, "Google Scholar SVG must precede the citation value inside its link")
      end
    end
  end

  def check_research_experiences
    headings = @document.css("h1, h2").select { |node| text(node) == "Research Experiences" }
    return unless check(headings.length == 1, "The experience section must be titled Research Experiences")

    check(headings.first["id"] == "-experiences", "Research Experiences must preserve its original -experiences anchor")
    list = headings.first.at_xpath("following-sibling::ul[1]")
    seed = list&.xpath("./li")&.find { |node| text(node).include?("ByteDance Seed") }
    return unless check(seed, "Research Experiences must retain the ByteDance Seed entry")

    copy = text(seed).tr("\u2019", "'")
    check(copy.include?("Research Intern on RL Scaling for General Agents (Seed-LLM Talent Program)"), "Seed experience must retain the approved RL Scaling role")
    check(copy.scan("Research Intern").length == 1 && !copy.include?("RL for Doubao's"), "Seed experience must not repeat the intern role or the superseded responsibilities line")
  end

  def check_section_headings
    headings = @document.css(".page__content > h1, .publications__intro > h1")
    expected = {
      "about-me" => "About me", "-news" => "News", "-educations" => "Educations",
      "-experiences" => "Research Experiences", "publications-heading" => "Selected Work",
      "selected-awards" => "Selected Awards", "-invited-talks" => "Invited Talks",
      "-academic-services" => "Academic Services"
    }
    check(headings.map { |heading| [heading["id"], text(heading)] } == expected.to_a, "Homepage must show eight icon-free section titles in the approved order, preserving their anchors")
    headings.each do |heading|
      check(heading["class"].to_s.split.include?("homepage-section-title"), "#{text(heading)} must share the homepage section-title style")
      check(heading.element_children.empty?, "#{text(heading)} must remain a plain-text title without icon elements")
    end
  end

  def check_selected_awards
    heading = @document.at_css("h1#selected-awards")
    return unless check(heading, "Homepage must include Selected Awards before Invited Talks")

    list = heading.next_element
    return unless check(list&.name == "ul", "Selected Awards must use one flat bullet list")

    check(list.xpath("./li").map { |item| text(item) } == SELECTED_AWARDS, "Selected Awards must retain the four approved 2026 bilingual entries and their exact distinctions")
    check(list.css("ul, ol, h2, h3").empty?, "Selected Awards must not introduce award subcategories or nested lists")
  end

  def check_author_contacts
    expected_url = "https://www.xiaohongshu.com/user/profile/5f266ae1000000000100a9cb"
    expected_wechat = "Xixi010111"
    author = @config["author"]
    check(author["xiaohongshu"] == expected_url, "Sidebar Xiaohongshu URL must be the user's canonical profile without temporary query parameters")
    check(author["wechat"] == expected_wechat, "Sidebar WeChat ID must match the user's supplied ID")
    %w[.author__urls .author__urls_sm].each do |selector|
      container = @document.at_css(selector)
      next unless check(container, "Missing author contact container #{selector}")

      links = container.css("a[data-xiaohongshu]")
      if check(links.length == 1, "#{selector}: expected one Xiaohongshu link")
        link = links.first
        check(link["href"] == expected_url, "#{selector}: Xiaohongshu link must not contain transient tokens")
        check(link["target"] == "_blank" && %w[noopener noreferrer].all? { |value| link["rel"].to_s.split.include?(value) }, "#{selector}: external social link needs safe new-tab attributes")
        check(text(link).include?("Xiaohongshu") || link["aria-label"] == "Xiaohongshu", "#{selector}: Xiaohongshu link needs an accessible name")
        check(link.at_css("img.author__social-icon[alt='']"), "#{selector}: use the existing decorative Xiaohongshu logo")
      end
      buttons = container.css("button[data-copy-wechat]")
      if check(buttons.length == 1, "#{selector}: expected one native WeChat copy button")
        button = buttons.first
        check(button["type"] == "button" && button["data-copy-wechat"] == expected_wechat, "#{selector}: WeChat button must copy the exact ID without submitting or navigating")
        check(button["aria-label"] == "Copy WeChat ID #{expected_wechat}" && button["title"].to_s.include?(expected_wechat), "#{selector}: copy action and account must be accessible")
        check(button.at_css("i.fa-weixin[aria-hidden='true']"), "#{selector}: WeChat needs its decorative brand icon")
      end
      statuses = container.css("[data-wechat-contact] [data-copy-status]")
      check(statuses.length == 1 && statuses.first["role"] == "status" && statuses.first["aria-live"] == "polite" && statuses.first["aria-atomic"] == "true" && text(statuses.first).empty?, "#{selector}: copy feedback must start empty and be announced accessibly")
    end
  end

  def check_news
    regions = @document.css(".news-scroll")
    return unless check(regions.length == 1, "Homepage must retain one scrollable News region")

    region = regions.first
    check(region["role"] == "region" && region["aria-labelledby"] == "-news" && region["tabindex"] == "0", "News scrolling region must be named and keyboard focusable")
    items = region.css("ul > li.news-item")
    dates = %w[2026-07 2026-06 2026-04 2026-03 2026-02 2025-09 2025-08 2025-06 2025-05 2024-03 2025-02 2023-12]
    check(items.length == dates.length, "News must retain all twelve existing entries")
    check(items.map { |item| item.at_css("time")&.[]("datetime") } == dates, "News dates and ordering must remain unchanged")
    items.each do |item|
      time = item.at_css("time[datetime]")
      check(time && text(time) == time["datetime"].tr("-", "."), "News date labels must match their machine-readable dates")
      check(item.element_children.map(&:name) == %w[time p], "News cards must separate the date and paragraph into two grid children")
      body = item.at_css("p > .news-item__text")
      check(body && nonempty?(text(body)), "Each News card must retain its event text")
      item.css("a[href]").each { |link| check(https?(link["href"]), "News links must retain HTTPS destinations") }
    end
  end

  def check_footer
    footers = @document.css("footer#footer.homepage-footer[data-site-origin]")
    return unless check(footers.length == 1, "Expected one semantic footer#footer.homepage-footer with data-site-origin")

    footer = footers.first
    check(footer["data-site-origin"] == @config["visitor_statistics_origin"], "Footer data-site-origin must equal configured visitor_statistics_origin, not a rewritten site.url")
    check(statically_visible?(footer), "Footer must remain visible on previews; hide only the analytics elements")
    metadata = footer.css(".homepage-footer__meta")
    if check(metadata.length == 1, "Footer must have one static .homepage-footer__meta block")
      meta = metadata.first
      check(statically_visible?(meta) && meta.css("*").all? { |node| statically_visible?(node) }, "Copyright, name, and last-updated metadata must remain visible without analytics")
      dates = meta.css("time[datetime]")
      if check(dates.length == 1, "Footer must render one static time[datetime] for its last update")
        date = iso_date(dates.first["datetime"])
        if check(date, "Footer time datetime must be a valid YYYY-MM-DD date")
          check(text(dates.first) == date.strftime("%b. %Y"), "Footer time text must match its month and year, such as Oct. 2026")
          check(text(meta).include?("\u00a9 #{date.year} #{SELF_NAME}"), "Footer must include the static copyright year and Xiaoxi Li")
          expected_meta = "\u00a9 #{date.year} #{SELF_NAME} Last updated #{date.strftime('%b. %Y')}"
          check(text(meta) == expected_meta, "Footer metadata must contain only its copyright, name, and Last updated time, not visitor totals")
        end
        check(text(meta).include?("Last updated #{text(dates.first)}"), "Footer must label its static time Last updated")
      end
      check(text(footer) == text(meta), "Footer must not contain hardcoded visitor totals or analytics placeholder text")
    end

    wrappers = footer.css(".visitor-badge")
    if check(wrappers.length == 1, "Footer must retain exactly one live visitor-badge wrapper")
      wrapper = wrappers.first
      check(wrapper.key?("hidden"), "Visitor badge must start hidden until its live SVG loads successfully")
      check(!overrides_hidden?(wrapper), "Visitor badge must not override its initial hidden state with inline display styles")
      check(!directly_hidden?(wrapper, allow_hidden_attribute: true), "Visitor badge must be revealable by removing its hidden attribute alone")
      check(statically_visible?(wrapper.parent), "Visitor badge must not be nested under permanently hidden analytics")
      check(text(wrapper).empty?, "Visitor badge must not contain a hardcoded total or placeholder")
      images = wrapper.css("img[data-visitor-badge][data-badge-source]")
      if check(images.length == 1, "Visitor badge must retain one dormant image with its source data")
        image = images.first
        check(image.parent == wrapper && !directly_hidden?(image), "Visitor badge image must be an unhidden direct child of its revealable wrapper")
        check(image["data-badge-source"] == VISITOR_BADGE_SOURCE, "Visitor badge must retain the approved legacy service, exact page_id with trailing slash, label, and colors")
        check(!image.key?("src") && !image.key?("srcset"), "Visitor badge must not request a source before the production-origin guard")
        check(image["alt"] == "Total Visitors (live visitor count)" && image["height"] == "18", "Visitor badge must retain its accessible live-count label and 18px height")
      end
    end
    check(@document.css("[data-visitor-badge], [data-badge-source]").length == 1, "Only one live visitor badge may be present in the active DOM")

    counters = footer.css(".site-traffic")
    if check(counters.length == 1, "Footer must preserve one background Busuanzi counter container")
      counter = counters.first
      check(counter.key?("hidden") && counter["aria-hidden"] == "true", "Busuanzi container must remain hidden and excluded from accessibility output")
      check(!overrides_hidden?(counter), "Busuanzi must not override its permanently hidden state with inline display styles")
      check(text(counter).empty?, "Busuanzi must not display a visitor label, count snapshot, or placeholder")
      check(counter.css("#busuanzi_container_site_pv #busuanzi_value_site_pv[data-traffic-value]").length == 1, "Background Busuanzi must retain its PV container and empty value")
      comments = counter.xpath(".//comment()")
      check(comments.any? { |comment| comment.content.include?("busuanzi_container_site_uv") && comment.content.include?("busuanzi_value_site_uv") }, "Keep the unused Unique Visitors markup commented out")
    end
    check(@document.css("[data-traffic-value]").map { |node| node["id"] } == ["busuanzi_value_site_pv"], "Only the background PV value may be present in the active DOM")
    check(@document.css("#busuanzi_container_site_uv, #busuanzi_value_site_uv").empty?, "Unique Visitors must stay commented out, not in the active DOM")
    check(@document.css("[data-visitor-map], [data-map-source], #clustrmaps").empty?, "Do not reactivate the unused visitor map or ClustrMaps")
    eager_sources = @document.css("[src], [srcset], [srcdoc], [poster], link[href], object[data], image, use, feimage").select do |node|
      %w[src srcset srcdoc poster href xlink:href data].any? { |key| node[key].to_s.match?(/visitor-badge\.laobi\.icu|busuanzi\.|clustrmaps\.com/i) }
    end
    check(eager_sources.empty?, "Visitor services must not have eager HTML sources that bypass the production-origin guard")
  end

  def local_anchor?(value)
    parsed = uri(value)
    parsed && parsed.scheme.nil? && parsed.host.nil? && ["", "/"].include?(parsed.path) && nonempty?(parsed.fragment)
  end

  def check_asset_versions
    versions = []
    baseurl = @config["baseurl"].to_s.delete_suffix("/")
    ASSET_ENTRYPOINTS.each do |path, (selector, attribute, deferred)|
      expected_path = "#{baseurl}#{path}"
      matches = @document.css(selector).select { |node| uri(node[attribute])&.path == expected_path }
      next unless check(matches.length == 1, "Asset #{path}: expected exactly one root-relative entrypoint")

      node = matches.first
      parsed = uri(node[attribute])
      check(parsed.scheme.nil? && parsed.host.nil? && parsed.fragment.nil?, "Asset #{path}: entrypoint must remain on the local site")
      params = URI.decode_www_form(parsed.query.to_s).select { |key, _| key == "v" }
      valid = params.length == 1 && params.first.last.match?(/\A[1-9]\d*\z/)
      check(valid, "Asset #{path}: needs one nonempty numeric build-version query parameter v")
      versions << params.first.last if valid
      built = File.join(File.dirname(html_path), path.delete_prefix("/"))
      check(File.file?(built) && File.size?(built), "Asset #{path}: missing or empty built file #{built}")
      next if deferred.nil?

      check(node.key?("defer") == deferred, "Asset #{path}: preserve its #{deferred ? 'deferred' : 'synchronous'} loading behavior")
      check(!node.key?("async"), "Asset #{path}: do not introduce unordered async loading")
    end
    check(versions.length == ASSET_ENTRYPOINTS.length && versions.uniq.length == 1, "Main CSS and all local JS entrypoints must share the same build version")
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
        check(text(matches.first) == group["short_title"], "Group navigation #{group['id']} must display its approved compact label")
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
      check(figure["href"] == image_url(paper, "image_full"), "#{id}: figure must link to its own full-size image with the correct image version")
      check(figure["data-figure-title"] == paper["title"], "#{id}: figure dialog title differs from data")
      if id == "seed2-1"
        expected_source = SEED_BANNER["figure_source_url"]
        expected_caption = "Project banner \u00b7 Project page"
        expected_source_label = "View project page"
      else
        expected_source = "#{paper['pdf_url']}#page=#{paper['figure_page']}"
        expected_caption = "#{paper['figure_label']} \u00b7 PDF page #{paper['figure_page']}"
        expected_source_label = "View this figure in the paper"
      end
      check(figure["data-figure-source"] == expected_source, "#{id}: enlarged figure must link to its exact PDF page or approved project page")
      check(figure["data-figure-caption"] == expected_caption, "#{id}: figure link must carry its exact source caption")
      check(figure["data-figure-source-label"] == expected_source_label, "#{id}: figure source label must distinguish the project page from a PDF figure")
      images = figure.css("img")
      if check(images.length == 1, "#{id}: figure link must contain exactly one thumbnail")
        image = images.first
        check(image["src"] == image_url(paper, "image"), "#{id}: thumbnail source or image version differs from data")
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
    check_ccf_rank_html(paper, card)
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
    check_media_html(paper, card)
    check_metrics(paper, card)
    check_authors(paper, card.at_css(".publication__authors"))
  end

  def image_url(paper, key)
    path = "#{@config['baseurl'].to_s.delete_suffix('/')}#{paper[key]}"
    paper["image_version"] ? "#{path}?v=#{paper['image_version']}" : path
  end

  def check_ccf_rank_html(paper, card)
    id = paper["id"]
    ranks = card.css(".venue-rank, [data-ccf-rank]")
    unless CCF_RANKS.key?(id)
      check(ranks.empty?, "#{id}: do not render a CCF label for a preprint or technical report")
      return
    end
    return unless check(ranks.length == 1, "#{id}: render exactly one CCF label")

    rank = ranks.first
    expected = CCF_RANKS[id]
    check(rank.name == "span" && rank["class"].to_s.split.include?("venue-rank") && rank["data-ccf-rank"] == expected, "#{id}: CCF label must be a span.venue-rank with data-ccf-rank=#{expected}")
    check(text(rank) == "CCF #{expected}", "#{id}: CCF label text must be CCF #{expected}")
    venue = card.at_css(".publication__venue")
    check(venue && rank.ancestors.include?(venue), "#{id}: CCF label must belong to its publication venue")
    check(!rank.key?("hidden") && rank.ancestors.none? { |node| node.key?("hidden") }, "#{id}: CCF label must remain visible")
  end

  def check_media_data(paper)
    id = paper["id"]
    links = paper.fetch("media_links", [])
    return unless check(links.is_a?(Array), "#{id}: media_links must be an array when present")

    links.each do |link|
      next unless check(link.is_a?(Hash), "#{id}: each media link must be an object")

      check(link.keys.sort == %w[label url], "#{id}: media links must contain only label and url")
      check(MEDIA_LABELS.include?(link["label"]), "#{id}: media label must use an approved publisher name")
      parsed = uri(link["url"])
      check(https?(link["url"]) && parsed.host == "mp.weixin.qq.com" && parsed.path.match?(%r{\A/s/[A-Za-z0-9_-]+\z}) && parsed.query.nil? && parsed.fragment.nil?, "#{id}: media URL must be a canonical HTTPS WeChat article")
    end
    pairs = links.select { |link| link.is_a?(Hash) }.map { |link| [link["label"], link["url"]] }
    check(pairs.map(&:last).uniq.length == pairs.length, "#{id}: media URLs must not repeat")
    check(pairs == APPROVED_MEDIA_LINKS.fetch(id, []), "#{id}: media links must retain the user-provided paper, publisher, URL, and order")
  end

  def check_media_html(paper, card)
    id = paper["id"]
    row = card.at_css(".publication__links")
    return unless check(row, "#{id}: publication link row is missing")

    links = card.css("[data-media-link]")
    expected = APPROVED_MEDIA_LINKS.fetch(id, [])
    check(links.map { |link| [text(link), link["href"]] } == expected, "#{id}: rendered media labels and destinations must match the approved articles")
    links.each do |link|
      check(link.name == "a" && link.parent == row, "#{id}: media links must be direct anchors, matching Paper and Code styling")
      check(statically_visible?(link), "#{id}: media links must remain visible regardless of metric counts")
      check(link["target"] == "_blank" && %w[noopener noreferrer].all? { |value| link["rel"].to_s.split.include?(value) }, "#{id}: media links need safe new-tab attributes")
      check(link.element_children.empty? && !link["class"].to_s.split.include?("publication__metric") && link.attribute_nodes.none? { |attribute| attribute.name.match?(/\Adata-(?:star|citation|emphasis)/) }, "#{id}: media links must stay plain text, without icons, badges, or metric hooks")
    end
    order = row.element_children.map do |link|
      if link.key?("data-media-link")
        "media"
      elsif link.key?("data-star-metric")
        "stars"
      elsif link.key?("data-citation-metric")
        "citations"
      else
        text(link)
      end
    end
    expected_order = []
    { "Project Page" => "project_url", "Paper" => "pdf_url", "arXiv" => "arxiv_url", "Code" => "code_url" }.each do |label, key|
      expected_order << label if paper[key]
    end
    expected_order.concat(Array.new(expected.length, "media"))
    expected_order << "stars" if paper["stars_url"]
    expected_order << "citations"
    check(order == expected_order, "#{id}: media must follow resource links and precede Stars/Citations, including hidden metrics")
  end

  def check_metrics(paper, card)
    id = paper["id"]
    order = card.css(".publication__links > [data-star-metric], .publication__links > [data-citation-metric]").map { |metric| metric.key?("data-star-metric") ? "stars" : "citations" }
    expected_order = paper["stars_url"] ? %w[stars citations] : %w[citations]
    check(order == expected_order, "#{id}: Selected Work must render Stars before Citations, including initially hidden metrics")
    citations = card.css("[data-citation-metric]")
    if check(citations.length == 1, "#{id}: keep one citation metric in the DOM, even when low or unknown")
      metric = citations.first
      threshold = @thresholds["citations_over"]
      check(metric["data-citation-threshold"] == threshold.to_s, "#{id}: rendered citation threshold differs from _config.yml")
      visible = valid_count?(paper["citations"]) && paper["citations"] > threshold
      check(metric.key?("hidden") == !visible, "#{id}: citation snapshot must be visible only when strictly > #{threshold}; unknown stays hidden")
      check_metric_emphasis(metric, paper["citations"], "citations_emphasis_min", "#{id}: citations")
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
    check_metric_emphasis(metric, paper["stars_count"], "stars_emphasis_min", "#{id}: stars")
    values = metric.xpath("./span[@data-github-stars]")
    check(values.length == 1 && text(values.first) == paper["stars_label"].to_s, "#{id}: Stars must preserve the original compact snapshot label")
    check(metric.css("img").empty?, "#{id}: Stars must be text, not an unreadable badge image")
    check(metric["href"] == paper["code_url"], "#{id}: Stars metric must link to its Code repository")
  end

  def check_metric_emphasis(metric, count, key, description)
    minimum = @thresholds[key]
    check(metric["data-emphasis-threshold"] == minimum.to_s, "#{description}: emphasis minimum must match _config.yml")
    emphasized = valid_count?(count) && count >= minimum
    check(metric["class"].to_s.split.include?("publication__metric--emphasized") == emphasized, "#{description}: bold emphasis must apply only at or above #{minimum}")
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
