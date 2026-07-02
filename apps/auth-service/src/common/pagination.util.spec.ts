import { parsePagination } from './pagination.util';

describe('parsePagination', () => {
  it('returns defaults when nothing is provided', () => {
    expect(parsePagination()).toEqual({ page: 1, limit: 20 });
  });

  it('parses valid page and limit', () => {
    expect(parsePagination('3', '50')).toEqual({ page: 3, limit: 50 });
  });

  it('clamps invalid or out-of-range values', () => {
    expect(parsePagination('-5', '9999')).toEqual({ page: 1, limit: 100 });
  });
});
