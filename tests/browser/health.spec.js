const { test, expect } = require('./fixtures');

for (const language of ['pt', 'en']) {
  test(`SNS 24 ${language}: discover, navigate and read on mobile`, async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto(`/servicos?lang=${language}`);
    await page.locator('#service-search').fill(language === 'en' ? 'prescription' : 'exames');
    await expect(page.locator('#service-results [data-service-id]:visible')).toHaveCount(1);
    await page.locator('[data-service-id="health"] a').click();
    await expect(page.locator('html')).toHaveAttribute('lang', language);
    await expect(page.locator('h1')).toHaveText(language === 'en' ? 'Find your healthcare route.' : 'Encontre o seu percurso de saúde.');
    await page.locator('a[href="#exams"]').click();
    await expect(page.locator('#exams')).toBeInViewport();
    for (const id of ['appointments', 'exams', 'medication', 'referrals']) {
      const card = page.locator(`article#${id}`);
      await expect(card.locator('h2')).not.toBeEmpty();
      expect(new URL(await card.locator('a.official').getAttribute('href')).hostname).toBe('www.sns24.gov.pt');
    }
    await expect(page.locator('#exams .notice')).toContainText(language === 'en' ? 'does not reserve a slot' : 'não reserva uma vaga');
    await expect(page.locator('form, input')).toHaveCount(0);
    for (const colorScheme of ['dark', 'light']) {
      await page.emulateMedia({ colorScheme });
      expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    }
  });
}

test.describe('SNS 24 without JavaScript', () => {
  test.use({ javaScriptEnabled: false });
  test('all four routes and official links remain usable', async ({ page }) => {
    await page.goto('/saude?lang=en');
    await expect(page.locator('article.card')).toHaveCount(4);
    await expect(page.locator('article a.official')).toHaveCount(4);
    await expect(page.locator('#medication')).toContainText('Approval by the health centre is required');
  });
});
