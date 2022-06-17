describe("empty spec", () => {
  it("passes", () => {
    cy.visit("/simple-example.html");
    cy.get("much-select").click();
    cy.get("much-select")
      .shadow()
      .find("#dropdown")
      .find("[data-value='Bricks']")
      .click();
    cy.get("much-select").should("have.attr", "selected-value", "Bricks");
    // cy.get("much-select")
    //   .shadow()
    //   .find("#dropdown")
    //   .should("have.class", "hiding");
  });
});
