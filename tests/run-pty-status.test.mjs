import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const config = JSON.parse(readFileSync(new URL("../run-pty.json", import.meta.url), "utf8"));
const htmlWatcher = config.find(({ title }) => title === "Build HTML for demo/sandbox site");
const rules = Object.entries(htmlWatcher.status).map(([pattern, status]) => [new RegExp(pattern), status]);

const statusAfterLine = (line, currentStatus = htmlWatcher.defaultStatus) =>
  rules.reduce(
    (status, [pattern, nextStatus]) => (pattern.test(line) ? nextStatus : status),
    currentStatus,
  );

test("HTML watcher marks Soupault as running", () => {
  assert.deepEqual(statusAfterLine("[Running: soupault]"), ["⏳", "W"]);
});

test("HTML watcher marks successful builds", () => {
  assert.deepEqual(statusAfterLine("[Command was successful]"), ["✅", "+"]);
});

test("HTML watcher marks nonzero child exits as errors", () => {
  assert.deepEqual(statusAfterLine("[Command exited with 42]"), ["🚨", "E"]);
});

test("HTML watcher marks timed-out child commands as errors", () => {
  assert.deepEqual(statusAfterLine("[Command timed out after 1s]"), ["🚨", "E"]);
});

test("HTML watcher marks ForceStop kills as errors", () => {
  assert.deepEqual(statusAfterLine("[Command killed by ForceStop]"), ["🚨", "E"]);
  assert.deepEqual(statusAfterLine("[Command was killed by ForceStop]"), ["🚨", "E"]);
});

test("a new Soupault run clears the previous error status", () => {
  assert.deepEqual(statusAfterLine("[Running: soupault]", ["🚨", "E"]), ["⏳", "W"]);
});