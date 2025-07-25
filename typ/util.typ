#import "@preview/unichar:0.3.0": codepoint

#import "templates/html-toolkit.typ": a, span, article, p
#import "templates/html-fix.typ": link-in-new-tab

/// Multilingual
#let _babel(en: [], zh: [], tag: "span") = {
  // Add “todo”
  if int(en != []) + int(zh != []) >= 1 {
    if zh == [] {
      zh = [TODO: 待译]
    }
    if en == [] {
      en = [TODO: to be translated]
    }
  }

  set text(lang: "en")
  html.elem(tag, en, attrs: (lang: "en", its-locale-filter-list: "en"))

  if tag == "span" { [ ] }

  set text(lang: "zh", region: "CN")
  html.elem(tag, zh, attrs: (lang: "zh-Hans", its-locale-filter-list: "zh"))
}
/// For paragraphs
#let babel = _babel.with(tag: "p")
/// For headings
#let bbl = _babel.with(tag: "span")


/// Link to a GitHub issue
///
/// - repo-num (str): Repo and issue number, e.g., `"typst#193"`, `"hayagriva#189"`
/// - anchor (str): Anchor in the page, e.g., `"#issuecomment-1855739446"`
/// - note (content): Annotation
/// -> content
#let issue(repo-num, anchor: "", note: auto) = {
  let (repo, num) = repo-num.split("#")
  if not repo.contains("/") {
    repo = "typst/" + repo
  }

  show link: link-in-new-tab.with(class: "unbreakable")
  link(
    "https://github.com/" + repo + "/issues/" + num + anchor,
    {
      span(
        class: "icon",
        // https://primer.style/octicons/icon/issue-opened-16/
        html.elem(
          "svg",
          attrs: (viewBox: "0 0 16 16", width: "16", height: "16"),
          {
            html.elem("path", attrs: (d: "M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Z"))
            html.elem(
              "path",
              attrs: (d: "M8 0a8 8 0 1 1 0 16A8 8 0 0 1 8 0ZM1.5 8a6.5 6.5 0 1 0 13 0 6.5 6.5 0 0 0-13 0Z"),
            )
          },
        ),
      )
      repo-num
      if note == auto {
        if anchor != "" { [~(comment)] }
      } else { [~(#note)] }
    },
  )
  [#metadata((repo-num: repo-num, note: repr(note))) <issue>]
}

/// Link to a workaround
///
/// - dest (str): URL
/// - note (content): Annotation
/// -> content
#let workaround(dest, note: none) = {
  let human-dest = if dest.starts-with("https://typst.app/universe/package/") {
    "universe/" + dest.trim("https://typst.app/universe/package/", at: start)
  } else {
    dest.trim("https://", at: start).split(".").at(0).trim("typst-", at: start)
  }

  let body = if note == none {
    [fix (#human-dest)]
  } else {
    [fix (#human-dest, #note)]
  }

  show link: link-in-new-tab.with(class: "unbreakable")
  link(
    dest,
    {
      span(
        class: "icon",
        // https://primer.style/octicons/icon/light-bulb-16/
        html.elem(
          "svg",
          attrs: (viewBox: "0 0 16 16", width: "16", height: "16"),
          html.elem(
            "path",
            attrs: (
              d: "M8 1.5c-2.363 0-4 1.69-4 3.75 0 .984.424 1.625.984 2.304l.214.253c.223.264.47.556.673.848.284.411.537.896.621 1.49a.75.75 0 0 1-1.484.211c-.04-.282-.163-.547-.37-.847a8.456 8.456 0 0 0-.542-.68c-.084-.1-.173-.205-.268-.32C3.201 7.75 2.5 6.766 2.5 5.25 2.5 2.31 4.863 0 8 0s5.5 2.31 5.5 5.25c0 1.516-.701 2.5-1.328 3.259-.095.115-.184.22-.268.319-.207.245-.383.453-.541.681-.208.3-.33.565-.37.847a.751.751 0 0 1-1.485-.212c.084-.593.337-1.078.621-1.489.203-.292.45-.584.673-.848.075-.088.147-.173.213-.253.561-.679.985-1.32.985-2.304 0-2.06-1.637-3.75-4-3.75ZM5.75 12h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1 0-1.5ZM6 15.25a.75.75 0 0 1 .75-.75h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1-.75-.75Z",
            ),
          ),
        ),
      )
      body
    },
  )
}

/// A formatted description of the Unicode character for a given codepoint
///
/// Usage: `unichar("‘")
#let unichar(code) = span(
  class: "unichar",
  {
    let c = codepoint(code)

    show smallcaps: span.with(class: "small-caps")

    span(class: "code-point")[U+#lower(c.id)]
    [~]
    raw(str.from-unicode(c.code))
    [ ]
    smallcaps(lower(c.name))
  },
)

/// Introduction of a section
///
/// If it is derived from #link("https://github.com/w3c/i18n-activity/blob/5cfa8e5d304c8db0473562defab7032d90217f1b/templates/gap-analysis/prompts.js")[W3C i18n-activity gap-analysis prompts],
/// then provide the URL as `from-w3c`.
///
/// - from-w3c (str): URL to the original W3C prompt, if applicable.
/// - body (content):
/// -> content
#let prompt(from-w3c: none, body) = article(
  class: "prompt",
  {
    body

    if from-w3c != none {
      p(class: "license")[
        #show link: link-in-new-tab
        #bbl(
          en: [(derived from #link(from-w3c)[a W3C document] under #a(target: "_blank", href: "https://www.w3.org/copyright/software-license-2023/", title: "Software and Document License")[its license])],
          zh: [（按#a(target: "_blank", href: "https://www.w3.org/zh-hans/copyright/software-license-2023/", title: "软件和文档许可协议")[相应协议]修改自 #link(from-w3c)[W3C 文档]）],
        )
      ]
    }
  },
)
