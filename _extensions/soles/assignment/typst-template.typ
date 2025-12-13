
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

  // Configure headings.
  show heading.where(level: 2): underline
  show heading.where(level: 2): set block(above: 2.5em, below: 1.5em)
  show heading.where(level: 3): set block(above: 2em, below: 1em)
  show heading.where(level: 4): set block(above: 2em, below: 1em)



  // Title block with logo on the left
  block(below: 1.5em)[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 1.5em,
      align: (left, left),
      // Logo column
      image("_extensions/soles/assignment/assets/images/usydlogo.png", width: 2cm),
      // Title/metadata column
      {
        if title != none {
          block(below: 1em)[
            #text(weight: "bold", size: 2.0em, font: ("Arial", "Helvetica", "sans-serif"))[#title]
          ]
        }
        
        if subtitle != none {
          block(below: 0.8em)[
            #text(size: 1.2em, font: ("Arial", "Helvetica", "sans-serif"))[#subtitle]
          ]
        }
        
        if authors != none {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          block(below: 0.5em)[
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
            #text(font: ("Arial", "Helvetica", "sans-serif"))[#date]
          ]
        }
      }
    )
  ]

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    block(above: 0em, below: 2em)[
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
