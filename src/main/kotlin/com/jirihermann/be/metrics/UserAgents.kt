package com.jirihermann.be.metrics

private val BOT_USER_AGENT = Regex(
  "bot|crawl|spider|slurp|curl|wget|python-requests|python-urllib|httpclient|okhttp|go-http-client|" +
    "java/|libwww|headless|facebookexternalhit|embedly|preview|monitor|uptime|pingdom|lighthouse",
  RegexOption.IGNORE_CASE,
)

/**
 * True for requests that are obviously not a person reading the page: no User-Agent, or one that
 * names a crawler, link previewer, monitor or HTTP library. A heuristic for view counters only.
 */
fun isLikelyBot(userAgent: String?): Boolean =
  userAgent.isNullOrBlank() || BOT_USER_AGENT.containsMatchIn(userAgent)
