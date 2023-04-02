import { LightningElement, api } from 'lwc';

/**
 * A simple paginator UI control for any results pagination.
 *
 * @fires SearchPaginatorCustom#previous
 * @fires SearchPaginatorCustom#next
 */
export default class SearchPaginatorCustom extends LightningElement {
    /**
     * The current page number.
     *
     * @type {Number}
     */
    @api pageNumber;

    /**
     * The number of items on a page.
     *
     * @type {Number}
     */
    @api pageSize;

    /**
     * The total number of items in the list.
     *
     * @type {Number}
     */
    @api totalItemCount;

    /**
     * Handles a user request to go to the previous page.
     *
     * @fires SearchPaginatorCustom#previous
     * @private
     */
    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    /**
     * Handles a user request to go to the next page.
     * @fires SearchPaginatorCustom#next
     * @private
     */
    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    /**
     * Gets the current page number.
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get currentPageNumber() {
        return this.totalItemCount === 0 ? 0 : this.pageNumber;
    }

    /**
     * Gets whether the current page is the first page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isFirstPage() {
        return this.pageNumber === 1;
    }

    /**
     * Gets whether the current page is the last page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    /**
     * Gets the total number of pages
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get totalPages() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }
}