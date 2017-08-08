moj.Modules.AmountAssessed = {
    $assessmentSection: $('#claim-status.js-cw-claim-assessment'),
    $actionSection: $('div.js-cw-claim-action'),
    $rejectionReasons: $('div.js-cw-claim-rejection-reasons'),

    init: function () {
        this.$rejectionReasons.hide();
        this.$actionSection.find('input:radio').on('change', function () {
            moj.Modules.AmountAssessed.state();
        });
    },
    state: function () {
        var action = this.$actionSection.find('input:radio:checked').val();

        if (action === 'part_authorised' || action === 'authorised') {
            this.$assessmentSection.slideDown('slow');
        } else {
            this.$assessmentSection.slideUp('slow');
        }

        if (action === 'rejected') {
            this.$rejectionReasons.show();
        } else {
            this.$rejectionReasons.hide();
            this.$rejectionReasons
                .find('input:radio:checked').prop('checked', false)
                .closest('label').removeClass('selected');
        }
    }
};
