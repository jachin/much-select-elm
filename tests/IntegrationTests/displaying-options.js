import { html, fixture, expect } from "@open-wc/testing";

import "../../src/much-select";

describe("MuchSelect", () => {
  it("creates an option if a value is set", async () => {
    const el = await fixture(html`
      <much-select selected-value="table"></much-select>
    `);

    expect(el.title).to.equal("Hey there");
    expect(el.counter).to.equal(5);
  });
});
