document.documentElement.classList.add('js');

const header = document.querySelector('.b-header');
const menu = document.querySelector('.b-menu');
const menuOpen = document.querySelector('.b-menu-btn');
const menuClose = document.querySelector('.b-menu__close');

function updateHeader() {
  if (header) header.classList.toggle('is-fixed', window.scrollY > 48);
}

function setMenu(open) {
  if (!menu || !menuOpen) return;
  menu.classList.toggle('is-open', open);
  document.body.classList.toggle('menu-open', open);
  menuOpen.setAttribute('aria-expanded', String(open));
}

window.addEventListener('scroll', updateHeader, { passive: true });
updateHeader();
menuOpen?.addEventListener('click', () => setMenu(true));
menuClose?.addEventListener('click', () => setMenu(false));
menu?.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => setMenu(false)));
document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') setMenu(false);
});

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (!entry.isIntersecting) return;
    entry.target.classList.add('is-visible');
    revealObserver.unobserve(entry.target);
  });
}, { threshold: 0.12 });

document.querySelectorAll('.b-reveal').forEach((element) => revealObserver.observe(element));

const contactForm = document.querySelector('.b-form');
contactForm?.addEventListener('submit', (event) => {
  event.preventDefault();
  const status = contactForm.querySelector('[role="status"]');
  if (status) status.textContent = 'こちらはデザイン確認用フォームです。送信機能は実装されていません。';
});
