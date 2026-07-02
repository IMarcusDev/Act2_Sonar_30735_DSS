export interface PaginationParams {
    page: number;
    limit: number;
}

const DEFAULT_PAGE = 1;
const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;

export function parsePagination(rawPage?: string, rawLimit?: string): PaginationParams {
    const page = Math.max(DEFAULT_PAGE, Number.parseInt(rawPage ?? '', 10) || DEFAULT_PAGE);
    const limit = Math.min(MAX_LIMIT, Math.max(1, Number.parseInt(rawLimit ?? '', 10) || DEFAULT_LIMIT));
    return { page, limit };
}
