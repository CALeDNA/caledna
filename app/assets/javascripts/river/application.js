// = require ../application

$(function () {
  // obscure contact email
  // https://stackoverflow.com/a/26420534
  function gen_mail_to_link(el, user, domain, tld) {
    const link = document.createElement("a");
    link.href = `mail01to23:${user}@${domain}.${tld}`;
    link.innerHTML = "email";
    el.appendChild(link);
  }

  let contactEmailEls = document.querySelectorAll(".contact-email");

  if (contactEmailEls.length > 0) {
    contactEmailEls.forEach((el) => {
      gen_mail_to_link(el, "Protecting12Our34River56", "g78mail90", "12com34");

      el.addEventListener("mouseover", (e) => {
        if (e.target.href && e.target.href.includes("mail01to23")) {
          e.target.href = e.target.href.replace(/\d/g, "");
          e.target.innerHTML = e.target.href.replace(/\d|mailto:/g, "");
        }
      });
    });
  }
});
