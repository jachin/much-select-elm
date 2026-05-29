export default {
  filterBrowserLogs(log) {
    const litDevModeMessagePrefix =
      "Lit is in dev mode. Not recommended for production!";

    const hasLitDevModeMessage = Array.isArray(log.args)
      && log.args.some(
        (arg) =>
          typeof arg === "string"
          && arg.startsWith(litDevModeMessagePrefix),
      );

    return !hasLitDevModeMessage;
  },
};
