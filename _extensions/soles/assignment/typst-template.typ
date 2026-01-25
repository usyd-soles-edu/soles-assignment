
// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find
// documentation on creating typst templates and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

// USYD Brand Colors - Canonical definitions
// Primary palette
#let usyd-ochre = rgb("#e64626")
#let usyd-charcoal = rgb("#424242")
#let usyd-sandstone = rgb("#fcede2")

// Neutrals
#let usyd-white = rgb("#ffffff")
#let usyd-black = rgb("#000000")
#let usyd-lightgrey = rgb("#f1f1f1")

// Accent colors
#let usyd-heritagerose = rgb("#daa8a2")
#let usyd-jacaranda = rgb("#8f9ec9")
#let usyd-navy = rgb("#1a355e")
#let usyd-eucalypt = rgb("#71a499")

// Legacy aliases (deprecated - use new names)
#let usyd-red = usyd-ochre
#let usyd-light = usyd-sandstone
#let usyd-dark = usyd-charcoal

// USYD Brand Fonts (Typst PDF only - HTML uses theme fonts)
#let usyd-font-sans = ("Arial", "Helvetica")

// USYD Spacing
#let spacing-xs = 0.5em
#let spacing-sm = 1em
#let spacing-md = 1.5em
#let spacing-lg = 2em
#let spacing-xl = 2.5em

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  logo: none,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  // Task list checkbox styling
  // Replace checkbox chars with boxes, using negative margin to replace the bullet
  // White fill covers the original bullet marker
  let checkbox-unchecked = box(stroke: 0.5pt + black, fill: white, width: 0.65em, height: 0.65em, baseline: 15%, inset: 0pt)
  let checkbox-checked = box(stroke: 0.5pt + black, fill: white, width: 0.65em, height: 0.65em, baseline: 15%, inset: 1pt)[#align(center + horizon, text(size: 0.6em)[✓])]

  // Pull checkbox into bullet position and push text back
  show "☐": h(-1.2em) + checkbox-unchecked + h(0.3em)
  show "☑": h(-1.2em) + checkbox-checked + h(0.3em)

  // Configure headings.
  show heading.where(level: 2): underline
  show heading.where(level: 2): set block(above: spacing-xl, below: spacing-md)
  show heading.where(level: 3): set block(above: spacing-lg, below: spacing-sm)
  show heading.where(level: 4): set block(above: spacing-lg, below: spacing-sm)

  // Code and output block styling (matches HTML styles.css)
  // Re-render raw content without Quarto's default block styling
  show raw.where(block: true): it => {
    // Extract text and re-render as inline raw to avoid default block styling
    let code-content = raw(it.text, lang: it.lang, block: false)

    if it.lang != none {
      // Code input block - has a language specified
      block(
        width: 100%,
        inset: 0pt,
        stroke: 0.5pt + usyd-charcoal.lighten(80%),
        above: 1.5em,
        below: 0.5em,
      )[
        // Header
        #block(
          width: 100%,
          fill: usyd-lightgrey,
          inset: (x: 0.8em, y: 0.4em),
          below: 0pt,
        )[
          #text(
            size: 0.7em,
            weight: 500,
            tracking: 0.05em,
            fill: usyd-charcoal,
          )[CODE]
        ]
        // Code content
        #block(
          width: 100%,
          fill: usyd-lightgrey,
          inset: (x: 0.8em, top: 0.5em, bottom: 1em),
          above: 0pt,
        )[
          #text(size: 1em)[#code-content]
        ]
      ]
    } else {
      // Output block - no language specified
      block(
        width: 100%,
        inset: 0pt,
        stroke: 0.5pt + usyd-charcoal.lighten(80%),
        above: 0pt,
        below: 1em,
      )[
        // Header
        #block(
          width: 100%,
          fill: usyd-white,
          inset: (x: 0.8em, y: 0.4em),
          below: 0pt,
        )[
          #text(
            size: 0.7em,
            weight: 500,
            tracking: 0.05em,
            fill: usyd-charcoal,
          )[OUTPUT]
        ]
        // Output content
        #block(
          width: 100%,
          fill: usyd-white,
          inset: (x: 0.8em, top: 0.5em, bottom: 1em),
          above: 0pt,
        )[
          #text(size: 0.95em)[#code-content]
        ]
      ]
    }
  }

  // Title block with logo on the left
  block(below: spacing-md)[
    #grid(
      columns: (auto, 1fr),
      column-gutter: spacing-md,
      align: (left, left),
      // Logo column
      image(if logo != none { logo } else { "_extensions/soles/assignment/assets/images/usydlogo.png" }, width: 2cm),
      // Title/metadata column
      {
        if title != none {
          block(below: spacing-sm)[
            #text(weight: "bold", size: 2.0em, font: usyd-font-sans)[#title]
          ]
        }

        if subtitle != none {
          block(below: 0.8em)[
            #text(size: 1.2em, font: usyd-font-sans)[#subtitle]
          ]
        }
        
        if authors != none {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          block(below: spacing-xs)[
            #grid(
              columns: (1fr,) * ncols,
              row-gutter: 1em,
              ..authors.map(author =>
                [
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
              )
            )
          ]
        }
        
        if date != none {
          block()[
            #text(font: usyd-font-sans)[#date]
          ]
        }
      }
    )
  ]

  if abstract != none {
    block(inset: spacing-lg)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    block(above: 0em, below: spacing-lg)[
    #outline(
      title: auto,
      depth: none
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
