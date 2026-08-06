/**

 * Riara University theme — editorial UI interactions.

 */

(function () {

	'use strict';



	document.addEventListener('DOMContentLoaded', function () {

		initDarkMode();

		initHomeReady();

		initScrollReveal();

		initSiteScrollReveal();

		initInnerScrollReveal();

		initSearchAdvancedToggle();

		initHeaderState();

		initImpactCounters();

		initPathwayProgress();

		initHeroParallax();

		initCitationCopy();

		initAuthPasswordToggle();

	});



	function initDarkMode() {

		var toggle = document.getElementById('riaraThemeToggle');

		var strings = window.riaraThemeStrings || {};

		var stored = null;



		try {

			stored = localStorage.getItem('riara-theme');

		} catch (e) {

			stored = null;

		}



		var prefersDark =

			window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

		var isDark =

			stored === 'dark' || (!stored && prefersDark && stored !== 'light');



		applyTheme(isDark ? 'dark' : 'light', false);



		if (!toggle) {

			return;

		}



		toggle.addEventListener('click', function () {

			var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';

			try {

				localStorage.setItem('riara-theme', next);

			} catch (e) {

				/* ignore */

			}

			applyTheme(next, true);

		});



		function applyTheme(mode, announce) {

			document.documentElement.setAttribute('data-theme', mode);

			var isDarkMode = mode === 'dark';

			toggle.setAttribute('aria-pressed', isDarkMode ? 'true' : 'false');

			toggle.setAttribute(

				'aria-label',

				isDarkMode

					? strings.themeLight || 'Switch to light mode'

					: strings.themeDark || 'Switch to dark mode'

			);

			if (announce) {

				toggle.blur();

			}

		}

	}



	function initHomeReady() {

		var home = document.querySelector('.riara-home');

		if (!home) {

			return;

		}



		requestAnimationFrame(function () {

			home.classList.add('is-ready');

		});

	}



	function initScrollReveal() {

		var home = document.querySelector('.riara-home');

		if (!home || !('IntersectionObserver' in window)) {

			return;

		}



		if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {

			return;

		}



		var targets = home.querySelectorAll(

			'.riara-section, .riara-pathway__step, .riara-bento__cell, .riara-cta-band__panel, ' +

			'.riara-impact, .riara-magazine, .riara-magazine__cover, .riara-about, ' +

			'.riara-trust, .obj_announcement_summary, .riara-announcement-card'

		);



		observeReveal(targets, { threshold: 0.05, rootMargin: '0px 0px 80px 0px' }, 0.05, 0.45);

	}



	function initSiteScrollReveal() {

		var site = document.querySelector('.riara-page--site');

		if (!site || !('IntersectionObserver' in window)) {

			return;

		}



		if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {

			return;

		}



		var targets = site.querySelectorAll(

			'.riara-site-hero, .riara-site-catalog, .riara-site-journal-card, .riara-trust, .riara-site-journal-card, .riara-announcements-grid, .riara-section'

		);



		observeReveal(targets, { threshold: 0.08, rootMargin: '0px 0px -30px 0px' }, 0.06, 0.4);

	}



	function observeReveal(targets, options, delayStep, maxDelay) {

		if (!targets.length) {

			return;

		}



		targets.forEach(function (el, index) {

			el.classList.add('riara-reveal');

			el.style.transitionDelay = Math.min(index * delayStep, maxDelay) + 's';

		});



		var observer = new IntersectionObserver(function (entries) {

			entries.forEach(function (entry) {

				if (entry.isIntersecting) {

					entry.target.classList.add('is-visible');

					observer.unobserve(entry.target);

				}

			});

		}, options);



		function revealIfVisible(el) {

			var rect = el.getBoundingClientRect();

			if (rect.top < window.innerHeight * 0.92 && rect.bottom > 0) {

				el.classList.add('is-visible');

				observer.unobserve(el);

			}

		}



		targets.forEach(function (el) {

			observer.observe(el);

		});



		requestAnimationFrame(function () {

			targets.forEach(revealIfVisible);

		});



		window.setTimeout(function () {

			targets.forEach(function (el) {

				if (!el.classList.contains('is-visible')) {

					el.classList.add('is-visible');

					observer.unobserve(el);

				}

			});

		}, 2500);

	}



	function initInnerScrollReveal() {

		var inner = document.querySelector('.riara-inner');

		if (!inner || !('IntersectionObserver' in window)) {

			return;

		}



		if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {

			return;

		}



		var targets = inner.querySelectorAll(

			'.riara-page__panel, .riara-article-card, .riara-archive__item, .riara-masthead-group, .riara-contact-card, .obj_article_details'

		);



		if (!targets.length) {

			return;

		}



		observeReveal(targets, { threshold: 0.06, rootMargin: '0px 0px -30px 0px' }, 0.04, 0.35);

	}



	function initSearchAdvancedToggle() {

		var toggle = document.querySelector('.riara-search-advanced-toggle');

		var panel = document.getElementById('riara-search-advanced');

		if (!toggle || !panel) {

			return;

		}



		var authorsEl = document.getElementById('authors');

		var dateFromYearEl = document.getElementById('dateFromYear');

		var hasValues =

			(authorsEl && authorsEl.value) ||

			(dateFromYearEl && dateFromYearEl.value);



		if (hasValues) {

			panel.hidden = false;

			toggle.setAttribute('aria-expanded', 'true');

		}



		toggle.addEventListener('click', function () {

			var expanded = toggle.getAttribute('aria-expanded') === 'true';

			toggle.setAttribute('aria-expanded', expanded ? 'false' : 'true');

			panel.hidden = expanded;

		});

	}



	function initHeaderState() {

		var header = document.querySelector('.pkp_structure_head');

		if (!header) {

			return;

		}



		var onScroll = function () {

			header.classList.toggle('riara-head--scrolled', window.pageYOffset > 16);

		};



		onScroll();

		window.addEventListener('scroll', onScroll, { passive: true });

	}



	function initImpactCounters() {

		if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {

			return;

		}



		var values = document.querySelectorAll('[data-riara-count]');

		if (!values.length || !('IntersectionObserver' in window)) {

			return;

		}



		var animate = function (el) {

			var target = parseInt(el.getAttribute('data-riara-count'), 10);

			if (isNaN(target) || target <= 0) {

				return;

			}



			var start = 0;

			var duration = 900;

			var startTime = null;



			function step(timestamp) {

				if (!startTime) {

					startTime = timestamp;

				}

				var progress = Math.min((timestamp - startTime) / duration, 1);

				var eased = 1 - Math.pow(1 - progress, 3);

				el.textContent = String(Math.round(start + (target - start) * eased));

				if (progress < 1) {

					requestAnimationFrame(step);

				}

			}



			el.textContent = '0';

			requestAnimationFrame(step);

		};



		var observer = new IntersectionObserver(

			function (entries) {

				entries.forEach(function (entry) {

					if (entry.isIntersecting) {

						animate(entry.target);

						observer.unobserve(entry.target);

					}

				});

			},

			{ threshold: 0.4 }

		);



		values.forEach(function (el) {

			observer.observe(el);

		});

	}



	function initPathwayProgress() {

		var pathway = document.querySelector('.riara-pathway');

		if (!pathway || !('IntersectionObserver' in window)) {

			return;

		}



		var steps = pathway.querySelectorAll('.riara-pathway__step');

		var progress = pathway.querySelector('.riara-pathway__progress span');

		if (!steps.length || !progress) {

			return;

		}



		var activeCount = 0;



		var updateProgress = function () {

			var width = steps.length <= 1 ? 100 : ((activeCount - 1) / (steps.length - 1)) * 100;

			progress.style.width = Math.max(0, Math.min(100, width)) + '%';

		};



		var observer = new IntersectionObserver(

			function (entries) {

				entries.forEach(function (entry) {

					var step = entry.target;

					if (entry.isIntersecting) {

						step.classList.add('is-active');

						var stepNum = parseInt(step.getAttribute('data-riara-step'), 10);

						if (!isNaN(stepNum)) {

							activeCount = Math.max(activeCount, stepNum);

							updateProgress();

						}

					}

				});

			},

			{ threshold: 0.45, rootMargin: '0px 0px -10% 0px' }

		);



		steps.forEach(function (step) {

			observer.observe(step);

		});

	}



	function initHeroParallax() {

		if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {

			return;

		}



		var cards = document.querySelectorAll('.riara-hero__float-card[data-parallax]');

		if (!cards.length) {

			return;

		}



		var onMove = function (event) {

			var x = (event.clientX / window.innerWidth - 0.5) * 2;

			var y = (event.clientY / window.innerHeight - 0.5) * 2;



			cards.forEach(function (card) {

				var strength = parseFloat(card.getAttribute('data-parallax')) || 0.05;

				card.style.transform =

					'translate(' + x * strength * 24 + 'px, ' + y * strength * 24 + 'px) rotate(' +

					(card.classList.contains('riara-hero__float-card--b') ? '2' : '-2') + 'deg)';

			});

		};



		window.addEventListener('mousemove', onMove, { passive: true });

	}



	function initCitationCopy() {

		var buttons = document.querySelectorAll('[data-riara-copy-target]');

		if (!buttons.length) {

			return;

		}



		var strings = window.riaraThemeStrings || {};

		var copiedLabel = strings.citationCopied || 'Copied!';



		buttons.forEach(function (button) {

			button.addEventListener('click', function () {

				var targetId = button.getAttribute('data-riara-copy-target');

				var target = targetId ? document.getElementById(targetId) : null;

				if (!target) {

					return;

				}



				var text = target.textContent || '';

				var onSuccess = function () {

					var label = button.querySelector('.riara-citation__copy-label');

					if (!label) {

						return;

					}

					var original = label.textContent;

					label.textContent = copiedLabel;

					button.classList.add('is-copied');

					window.setTimeout(function () {

						label.textContent = original;

						button.classList.remove('is-copied');

					}, 2000);

				};



				if (navigator.clipboard && navigator.clipboard.writeText) {

					navigator.clipboard.writeText(text.trim()).then(onSuccess).catch(function () {

						legacyCopy(text, onSuccess);

					});

				} else {

					legacyCopy(text, onSuccess);

				}

			});

		});



		function legacyCopy(text, callback) {

			var area = document.createElement('textarea');

			area.value = text.trim();

			area.setAttribute('readonly', '');

			area.style.position = 'absolute';

			area.style.left = '-9999px';

			document.body.appendChild(area);

			area.select();

			try {

				document.execCommand('copy');

				callback();

			} catch (e) {

				/* ignore */

			}

			document.body.removeChild(area);

		}

	}

	function initAuthPasswordToggle() {
		var toggles = document.querySelectorAll('[data-riara-password-toggle]');
		if (!toggles.length) {
			return;
		}

		var strings = window.riaraThemeStrings || {};

		toggles.forEach(function (toggle) {
			var selector = toggle.getAttribute('data-riara-password-toggle');
			var input = selector ? document.querySelector(selector) : null;
			var icon = toggle.querySelector('.fa');
			if (!input || !icon) {
				return;
			}

			toggle.addEventListener('click', function () {
				var isVisible = input.type === 'text';
				input.type = isVisible ? 'password' : 'text';
				toggle.setAttribute('aria-pressed', isVisible ? 'false' : 'true');
				icon.classList.toggle('fa-eye', isVisible);
				icon.classList.toggle('fa-eye-slash', !isVisible);
				toggle.setAttribute(
					'aria-label',
					isVisible
						? strings.showPassword || 'Show password'
						: strings.hidePassword || 'Hide password'
				);
			});
		});
	}

})();

