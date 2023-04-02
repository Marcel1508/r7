import { LightningElement, api } from 'lwc';
import { capitalizeAllWords } from 'c/cartUtilsCustom';

/**
 * An organized display of the given category and it's children.
 *
 * @fires SearchCategoryCustom#categoryupdate
 */
export default class SearchCategoryCustom extends LightningElement {
    /**
     * An event fired when the user has selected a category.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *
     * @event SearchCategoryCustom#categoryupdate
     * @type {CustomEvent}
     *
     * @property {string} categoryId
     *   The unique identifier of the category.
     *
     * @export
     */

    /**
     * Gets or sets the display data for categories.
     *
     * @type {ConnectApi.SearchCategoryCustom}
     * @private
     */
    @api
    displayData;

    /**
     * Gets the current category data.
     *
     * @type {ConnectApi.ProductCategoryData}
     * @readonly
     * @private
     */
    get category() {
        return (this.displayData || {}).category || {};
    }

    /**
     * Gets the children of the current category.
     *
     * @type {object}
     * @readonly
     * @private
     */
    get children() {
        return ((this.displayData || {}).children || []).map(
            ({ category, productCount }) => ({
                id: category.id,
              // displayName: capitalizeAllWords(category.name),
                displayName: category.name,
                productCount: productCount
            })
        );
    }

    get activeSections() {
        return this._sections ? this._sections : ['category'];
    }

    handleSectionToggle(event) {
        this._sections = event.detail.openSections;
    }

    /**
     * Emits a notification that the user has selected a category.
     *
     * @fires SearchCategoryCustom#categoryupdate
     * @private
     */
    notifyCategorySelection(evt) {
        const { categoryId } = evt.target.dataset;

        this.dispatchEvent(
            new CustomEvent('categoryupdate', {
                bubbles: true,
                composed: true,
                detail: { categoryId }
            })
        );
    }

    _sections;
}