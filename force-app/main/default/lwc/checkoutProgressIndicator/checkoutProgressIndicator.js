import { LightningElement, api } from 'lwc';

export default class B2blCheckoutProgressIndicator extends LightningElement {
  @api checkoutStages;
  @api currentStage;
  @api marginBottomSize = 'none';

  get stagesEnriched() {
    const currentStageIndex = this.stages.indexOf(this.currentStage);
    return this.stages.map((stage, index) => {
      const isComplete = index < currentStageIndex;
      const isCurrent = index === currentStageIndex;
      const stageClass = isComplete ? 'slds-is-complete' : isCurrent ? 'slds-is-current' : 'slds-is-incomplete';
      const assistiveText = isComplete ? 'Stage Complete' : isCurrent ? 'Current Stage' : null;
      return {
        label: stage,
        isComplete,
        assistiveText,
        hasAssistiveText: assistiveText !== null,
        class: `slds-path__item ${stageClass}`
      };
    });
  }

  get stages() {
    return this.checkoutStages ? this.checkoutStages.split(',') : [];
  }

  get hasStages() {
    return this.stages && this.stages.length > 0;
  }

  get progressIndicatorClass() {
    return `checkout-progress-indicator slds-path slds-var-m-bottom_${this.marginBottomSize}`;
  }
}