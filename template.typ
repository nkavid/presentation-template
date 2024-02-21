#let combitechdarkblue = rgb("064182")
#let combitechdarkmagenta = rgb("cd0c59")
#let combitechdarkgreen = rgb("65b01e")
#let codelistinggray = rgb("e0e0e0")

#let frontpage(title: "", author: "", role: "") = {
  align(right, image("assets/combitech_logo_blue.jpg", width: 20%))
  v(160pt)
  rect(
    fill: gradient.linear(combitechdarkblue, combitechdarkgreen, white),
    width: 100%,
    outset: 20pt,
    text(font: "RobotoLight", fill: white, size: 40pt, upper(title)),
  )
  v(40pt)
  text(size: 20pt, author)
  linebreak()
  text(size: 10pt, role)
}

#let slide(title: "", body) = {
  set page(
    header: text(font: "RobotoLight", size: 20pt, weight: "bold", upper(title)),
    footer: text(counter(page).display()),
    numbering: "- 1 -",
    number-align: center,
  )
  line(start: (-20pt, 0pt), length: 100% + 20pt*2, stroke: 2pt + gradient.linear(combitechdarkblue, combitechdarkgreen, white))
  v(10pt)
  body
}
