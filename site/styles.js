document.addEventListener("DOMContentLoaded", () => {
  const themes = ["loading", "fun", "boring"];

  const setTheme = (newTheme) => {
    const body = document.querySelector("body");
    themes.map((theme) => body.classList.remove(theme));
    body.classList.add(newTheme);
    localStorage.setItem("page-theme", newTheme);
  };

  // Setup handlers on the buttons for switching themes
  document.getElementById("fun-style").addEventListener("click", () => {
    setTheme("fun");
  });
  document.getElementById("boring-style").addEventListener("click", () => {
    setTheme("boring");
  });

  // Set the initial page theme
  let initialPageTheme = localStorage.getItem("page-theme");
  if (!initialPageTheme) {
    // default theme
    initialPageTheme = "fun";
  }
  setTheme(initialPageTheme);
});
