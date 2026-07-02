import { slugify } from './slug.util';

describe('slugify', () => {
  it('lowercases and replaces spaces with hyphens', () => {
    expect(slugify('Hello World')).toBe('hello-world');
  });

  it('strips accents', () => {
    expect(slugify('Catálogo Épico')).toBe('catalogo-epico');
  });

  it('trims leading and trailing separators', () => {
    expect(slugify('  --Nuevo Usuario!!--  ')).toBe('nuevo-usuario');
  });
});
