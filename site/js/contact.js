(function () {
  "use strict";

  var contactReveal = document.getElementById("contact-reveal");

  function showContact() {
    if (!contactReveal) return;
    contactReveal.hidden = false;
    contactReveal.classList.add("is-revealed");
  }

  if (contactReveal) {
    if (location.hash === "#contact") {
      showContact();
    } else {
      contactReveal.hidden = true;
    }

    var cta = document.querySelector('a[href="#contact"]');
    if (cta) {
      cta.addEventListener("click", function (event) {
        event.preventDefault();
        showContact();
        history.pushState(null, "", "#contact");
        document.getElementById("contact").scrollIntoView({ behavior: "smooth" });
        var nameField = document.getElementById("name");
        if (nameField) nameField.focus();
      });
    }

    window.addEventListener("hashchange", function () {
      if (location.hash === "#contact") showContact();
    });
  }

  var form = document.getElementById("contact-form");
  if (!form) return;

  var submitBtn = document.getElementById("submit-btn");
  var messageEl = document.getElementById("form-message");

  function showMessage(text, type) {
    messageEl.textContent = text;
    messageEl.className = "form-message visible " + type;
  }

  function clearMessage() {
    messageEl.textContent = "";
    messageEl.className = "form-message";
  }

  function markInvalid(field, invalid) {
    if (invalid) {
      field.classList.add("invalid");
    } else {
      field.classList.remove("invalid");
    }
  }

  function validateEmail(value) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  }

  function validateForm(data) {
    var valid = true;

    markInvalid(data.nameEl, !data.name);
    if (!data.name) valid = false;

    markInvalid(data.emailEl, !validateEmail(data.email));
    if (!validateEmail(data.email)) valid = false;

    markInvalid(data.messageEl, !data.message);
    if (!data.message) valid = false;

    return valid;
  }

  form.addEventListener("submit", function (event) {
    event.preventDefault();
    clearMessage();

    var nameEl = document.getElementById("name");
    var emailEl = document.getElementById("email");
    var phoneEl = document.getElementById("phone");
    var messageField = document.getElementById("message");

    var payload = {
      name: nameEl.value.trim(),
      email: emailEl.value.trim(),
      phone: phoneEl.value.trim(),
      message: messageField.value.trim(),
      nameEl: nameEl,
      emailEl: emailEl,
      messageEl: messageField,
    };

    if (!validateForm(payload)) {
      showMessage("Please fill in all required fields with valid information.", "error");
      return;
    }

    var apiUrl = window.CONTACT_CONFIG && window.CONTACT_CONFIG.apiUrl;
    if (!apiUrl || apiUrl === "__CONTACT_API_URL__") {
      showMessage("Contact form is not configured yet. Please email us directly.", "error");
      return;
    }

    submitBtn.disabled = true;
    submitBtn.textContent = "Sending…";

    fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: payload.name,
        email: payload.email,
        phone: payload.phone || undefined,
        message: payload.message,
      }),
    })
      .then(function (response) {
        return response.json().then(function (body) {
          return { ok: response.ok, body: body };
        });
      })
      .then(function (result) {
        if (result.ok) {
          form.reset();
          showMessage("Thank you! Your message has been sent.", "success");
        } else {
          showMessage(result.body.error || "Something went wrong. Please try again.", "error");
        }
      })
      .catch(function () {
        showMessage("Unable to send your message. Please try again or email us directly.", "error");
      })
      .finally(function () {
        submitBtn.disabled = false;
        submitBtn.textContent = "Send Message";
      });
  });
})();
