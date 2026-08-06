import { test, expect } from '@playwright/test';

const JOURNAL = '/index.php/riara';
const ARTICLE_ID = process.env.OJS_TEST_ARTICLE_ID || '1';

test.describe('Public pages', () => {
  test('journal homepage loads with custom theme', async ({ page }) => {
    await page.goto(JOURNAL);
    await expect(page.locator('.riara-hero')).toBeVisible();
    await expect(page.locator('link[rel="stylesheet"]').first()).toBeAttached();
  });

  test('navigation links work', async ({ page }) => {
    await page.goto(`${JOURNAL}/about`);
    await expect(page).toHaveURL(/\/about/);
    await expect(page.locator('h1').first()).toBeVisible();
  });
});

test.describe('Authentication', () => {
  test('admin can log in', async ({ page }) => {
    await page.goto('/index.php/index/en/login');
    await page.locator('input[name="username"]').fill('root');
    await page.locator('input[name="password"]').fill('root');
    await page.locator('form#login').evaluate((form: HTMLFormElement) => form.submit());
    await page.waitForURL(/dashboard|riara/, { timeout: 15_000 });
    await expect(page.locator('body')).not.toContainText('Invalid');
  });

  test('author can log in', async ({ page }) => {
    await page.goto(`${JOURNAL}/login`);
    await page.locator('input[name="username"]').fill('author');
    await page.locator('input[name="password"]').fill('test123');
    await page.locator('form#login').evaluate((form: HTMLFormElement) => form.submit());
    await page.waitForURL(/dashboard|riara/, { timeout: 15_000 });
  });

  test('reviewer can log in', async ({ page }) => {
    await page.goto(`${JOURNAL}/login`);
    await page.locator('input[name="username"]').fill('reviewer');
    await page.locator('input[name="password"]').fill('test123');
    await page.locator('form#login').evaluate((form: HTMLFormElement) => form.submit());
    await page.waitForURL(/dashboard|riara/, { timeout: 15_000 });
  });
});

test.describe('Published content', () => {
  test('published article page loads', async ({ page }) => {
    await page.goto(`${JOURNAL}/article/view/${ARTICLE_ID}`);
    await expect(page.locator('.riara-article-hero__title')).toBeVisible({ timeout: 15_000 });
  });
});
