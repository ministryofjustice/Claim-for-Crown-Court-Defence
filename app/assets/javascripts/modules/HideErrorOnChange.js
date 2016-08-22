moj.Modules.HideErrorOnChange = {
    el: '.form-group.field_with_errors',
    dd: '.dropdown_field_with_errors',
    dates: 'fieldset.gov_uk_date.error',
    $el: null,
    $dd: null,
    $dates: null,

    init: function() {
        console.log("Firing now");
        this.$el = $(this.el);
        this.$dd = $(this.dd);
        this.$dates = $(this.dates);

        this.bindEvents();
        console.log(this);
    },

    bindEvents: function() {
        this.$el.each( function(idx, el) {
            $(el).on('focus', 'input', function(e) {
                $(e.delegateTarget).removeClass('field_with_errors');
                $(e.delegateTarget).find('.error').remove();
            })
        })

        this.$dd.each(function(idx, el) {
            $(el).on('focus', 'input', function(e) {
                $(e.delegateTarget).removeClass('dropdown_field_with_errors');
                $(e.delegateTarget).find('.error').remove();
            })
        })

        this.$dates.each(function(idx, el) {
            $(el).on('focus', 'input', function(e) {
                $(e.delegateTarget).removeClass('error');
                $(e.delegateTarget).find('ul').remove();
            })

        })
    }


};
