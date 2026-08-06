import { test, expect } from '@playwright/test';

const JOURNAL = '/index.php/riara';
const ARTICLE_ID = process.env.OJS_TEST_ARTICLE_ID || '1';

test.describe('Homepage design system', () => {
  test('hero, bento, pathway, and footer render', async ({ page }) => {
    await page.goto(JOURNAL);
    await expect(page.locator('.riara-hero')).toBeVisible();
    await expect(page.locator('.riara-marquee')).toBeVisible();
    await expect(page.locator('.riara-impact')).toBeVisible();
    await expect(page.locator('.riara-bento')).toBeVisible();
    await expect(page.locator('.riara-pathway')).toBeVisible();
    await expect(page.locator('.riara-footer')).toBeVisible();
    await expect(page.locator('.riara-search')).toBeVisible();
  });

  test('homepage has search input ready', async ({ page }) => {
    await page.goto(JOURNAL);
    await expect(page.locator('#riara-search-input')).toBeVisible();
    await expect(page.locator('a.riara-bento__cell[href*="search"]')).toBeVisible();
  });

  test('homepage uses Riara University branding', async ({ page }) => {
    await page.goto(JOURNAL);
    const html = await page.content();
    expect(html).not.toContain('Open Journal Systems');
    expect(html).not.toContain('pkp_brand_footer');
    await expect(page.locator('.riara-footer__copyright')).toContainText('Riara University');
    await expect(page.locator('.riara-footer__publisher a')).toHaveAttribute('href', 'https://riarauniversity.ac.ke');
  });
});

test.describe('Multi-journal hub', () => {
  test('site index lists faculty journals', async ({ page }) => {
    await page.goto('/index.php/index');
    await expect(page.locator('.riara-site-hub')).toBeVisible();
    await expect(page.locator('.riara-site-catalog')).toBeVisible();
    await expect(page.locator('.riara-site-journal-card').first()).toBeVisible({ timeout: 15_000 });
    expect(await page.locator('.riara-site-journal-card').count()).toBeGreaterThanOrEqual(2);
    await expect(page.locator('a[href*="/index.php/law"]')).toBeVisible();
    await expect(page.locator('a[href*="/index.php/engineering"]')).toBeVisible();
  });

  test('law faculty journal homepage loads', async ({ page }) => {
    await page.goto('/index.php/law');
    await expect(page.locator('.riara-hero, .riara-page')).toBeVisible({ timeout: 15_000 });
    await expect(page.locator('.riara-brand-bar')).toBeVisible();
  });
});

test.describe('Journal inner pages', () => {
  test('about page loads', async ({ page }) => {
    await page.goto(`${JOURNAL}/about`);
    await expect(page.locator('.riara-page--about')).toBeVisible();
    await expect(page.locator('h1').first()).toBeVisible();
    await expect(page.locator('.riara-footer')).toBeVisible();
  });

  test('platform page loads with Riara branding', async ({ page }) => {
    await page.goto(`${JOURNAL}/about/aboutThisPublishingSystem`);
    await expect(page.locator('.riara-page--platform')).toBeVisible();
    await expect(page.getByRole('heading', { name: /Riara University Publishing/i })).toBeVisible();
    const html = await page.content();
    expect(html).not.toContain('Open Journal Systems');
    expect(html).not.toContain('pkp_brand_footer');
  });

  test('submissions page loads', async ({ page }) => {
    await page.goto(`${JOURNAL}/about/submissions`);
    await expect(page).toHaveURL(/submissions/);
    await expect(page.locator('.riara-page--submissions')).toBeVisible();
    await expect(page.locator('h1, h2').first()).toBeVisible();
  });

  test('search page has themed layout', async ({ page }) => {
    await page.goto(`${JOURNAL}/search`);
    await expect(page.locator('.riara-page--search')).toBeVisible();
    await expect(page.locator('.riara-search--page')).toBeVisible();
  });

  test('issue archive has themed layout', async ({ page }) => {
    await page.goto(`${JOURNAL}/issue/archive`);
    await expect(page.locator('.riara-page--archive')).toBeVisible({ timeout: 15_000 });
  });

  test('current issue page loads', async ({ page }) => {
    await page.goto(`${JOURNAL}/issue/current`);
    await expect(page.locator('.riara-page--issue')).toBeVisible({ timeout: 15_000 });
  });

  test('privacy and contact pages load', async ({ page }) => {
    await page.goto(`${JOURNAL}/about/privacy`);
    await expect(page.locator('.riara-page--privacy')).toBeVisible();
    await expect(page.locator('.riara-about-layout')).toBeVisible();
    await page.goto(`${JOURNAL}/about/contact`);
    await expect(page.locator('.riara-page--contact')).toBeVisible();
    await expect(page.locator('.riara-about-nav')).toBeVisible();
  });

  test('login page uses auth layout', async ({ page }) => {
    await page.goto(`${JOURNAL}/login`);
    await expect(page.locator('.riara-page--auth')).toBeVisible();
    await expect(page.locator('.riara-auth__form-card')).toBeVisible();
    await expect(page.locator('.riara-brand-bar')).toBeVisible();
  });

  test('login page shows Google sign-in when configured', async ({ page }) => {
    await page.goto(`${JOURNAL}/login`);
    const googleButton = page.locator('.riara-btn--google');
    if (await googleButton.count()) {
      await expect(googleButton).toBeVisible();
      await expect(googleButton).toContainText('Sign in with Google');
      await expect(googleButton).toHaveAttribute('href', /googleoauth\/connect/);
    }
  });

  test('lost password page uses auth layout', async ({ page }) => {
    await page.goto(`${JOURNAL}/login/lostPassword`);
    await expect(page.locator('.riara-page--auth')).toBeVisible();
    await expect(page.locator('#lostPasswordForm')).toBeVisible();
  });

  test('announcements and editorial history pages load', async ({ page }) => {
    await page.goto(`${JOURNAL}/announcement`);
    await expect(page.locator('.riara-page--announcements')).toBeVisible();
    await page.goto(`${JOURNAL}/about/editorialHistory`);
    await expect(page.locator('.riara-page--history')).toBeVisible();
  });

  test('policy and indexing static pages load', async ({ page }) => {
    const routes = [
      '/about/policies',
      '/about/indexing',
      '/about/ethics',
      '/about/peer-review',
      '/about/copyright',
      '/about/preservation',
      '/about/metrics',
    ];
    for (const route of routes) {
      await page.goto(`${JOURNAL}${route}`);
      await expect(page.locator('.riara-page--static')).toBeVisible();
    }
    await page.goto(`${JOURNAL}/about/indexing`);
    await expect(page.locator('a[href*="sitemap"]')).toBeVisible();
  });

  test('submissions page shows author guidelines', async ({ page }) => {
    await page.goto(`${JOURNAL}/about/submissions`);
    await expect(page.locator('.riara-page--submissions')).toBeVisible();
    await expect(page.getByText('APA 7th edition').first()).toBeVisible();
  });
});

test.describe('Published content', () => {
  test('published article page has themed layout', async ({ page }) => {
    await page.goto(`${JOURNAL}/article/view/${ARTICLE_ID}`);
    await expect(page.locator('.riara-page--article')).toBeVisible();
    await expect(page.locator('.riara-article-hero')).toBeVisible();
    await expect(page.locator('.riara-article-hero__title')).toBeVisible();
    await expect(page.locator('.riara-citation')).toBeVisible();
    await expect(page.locator('.obj_article_details')).toBeVisible();
  });

  test('issue page has magazine hero', async ({ page }) => {
    await page.goto(`${JOURNAL}/issue/view/1`);
    await expect(page.locator('.riara-page--issue')).toBeVisible({ timeout: 15_000 });
    await expect(page.locator('.riara-issue-hero')).toBeVisible();
    await expect(page.locator('.riara-issue-toc-heading')).toBeVisible();
  });
});

test.describe('Responsive layout', () => {
  test('homepage renders on mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto(JOURNAL);
    await expect(page.locator('.riara-hero__title')).toBeVisible();
    await expect(page.locator('.riara-bento')).toBeVisible();
  });
});
