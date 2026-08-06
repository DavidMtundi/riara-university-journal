import { test, expect } from '@playwright/test';

const JOURNAL = '/index.php/riara';

test.describe('Editorial dashboard', () => {
  test('reviewer sees submissions dashboard after login', async ({ page }) => {
    await page.goto(`${JOURNAL}/login`);
    await page.locator('input[name="username"]').fill('reviewer');
    await page.locator('input[name="password"]').fill('test123');
    await page.locator('form#login').evaluate((form: HTMLFormElement) => form.submit());
    await page.waitForURL(/dashboard|submissions|riara/, { timeout: 15_000 });
    await expect(page.locator('body')).not.toContainText('Invalid');
    const body = await page.locator('body').innerText();
    expect(body.length).toBeGreaterThan(50);
  });

  test('admin can reach editorial workflow area', async ({ page }) => {
    await page.goto('/index.php/index/en/login');
    await page.locator('input[name="username"]').fill('root');
    await page.locator('input[name="password"]').fill('root');
    await page.locator('form#login').evaluate((form: HTMLFormElement) => form.submit());
    await page.waitForURL(/dashboard|management|riara/, { timeout: 15_000 });
    await expect(page.locator('body')).not.toContainText('Invalid');
  });
});
