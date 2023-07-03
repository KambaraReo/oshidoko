document.addEventListener('turbolinks:load', () => {
  function togglePasswordVisibility(passwordField, passwordToggle) {
    if (passwordField.type === "password") {
      passwordField.type = "text";
      passwordToggle.innerHTML = '<i class="fa-solid fa-eye-slash"></i>';
    } else {
      passwordField.type = "password";
      passwordToggle.innerHTML = '<i class="fa-solid fa-eye"></i>';
    }
  }

  const passwordField1 = document.querySelector(".password-field");
  const passwordField2 = document.querySelector(".password-confirmation-field");
  const passwordToggle1 = document.getElementById("password-toggle");
  const passwordToggle2 = document.getElementById("password-confirmation-toggle");

  if (passwordField1 && passwordToggle1 && passwordField2 && passwordToggle2) {
    passwordToggle1.addEventListener("click", () => {
      togglePasswordVisibility(passwordField1, passwordToggle1);
    });
    passwordToggle2.addEventListener("click", () => {
      togglePasswordVisibility(passwordField2, passwordToggle2);
    });
  } else if (passwordField1 && passwordToggle1) {
    passwordToggle1.addEventListener("click", () => {
      togglePasswordVisibility(passwordField1, passwordToggle1);
    });
  } else {
    return false;
  }
})
