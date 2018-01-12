moj.Modules.AmountAssessed = {
  blocks: [],
  init: function() {
    this.blocks.push(new moj.Modules.AmountAssessedBlock());
  }
};


moj.Modules.AmountAssessedBlock = function(selector) {
  var self = this;

  this.config = {
    hook: selector || '.fx-assesment-hook',
    form: '.js-cw-claim-assessment',
    actions: '.js-cw-claim-action',
    reasons: '.js-cw-claim-rejection-reasons',
    refuseReasons: '.js-cw-claim-refuse-reasons',
    otherinput: '.js-reject-reason-text',
    otherRefuseInput: '.js-refuse-reason-text',
    otherCheckbox: '#_state_reason_other',
    otherRefuseCheckbox: '#_state_reason_other_refuse',
    action: 'toggle'
  };

  this.states = {
    rejected: {
      form: false,
      reasons: true,
      refuseReasons: false
    },
    refused: {
      form: false,
      reasons: false,
      refuseReasons: true
    },
    authorised: {
      form: true,
      reasons: false,
      refuseReasons: false
    },
    part_authorised: {
      form: true,
      reasons: false,
      refuseReasons: false
    }
  };

  this.el = this.config.hook;

  this.init = function() {
    this.$el = $(this.el);
    this.$form = $(this.config.form);
    this.$actions = $(this.config.actions);
    this.$reasons = $(this.config.reasons);
    this.$refuseReasons = $(this.config.refuseReasons);
    this.$otherinput = $(this.config.otherinput);
    this.$otherRefuseInput = $(this.config.otherRefuseInput);
    this.$otherCheckbox = $(this.config.otherCheckbox);
    this.$otherRefuseCheckbox = $(this.config.otherRefuseCheckbox);
    this.bindEvents();
  };

  this.slider = function(state, el) {
    // open and close slider
    // true: open
    // false: close
    return state ? $(el).slideDown() : $(el).slideUp();
  };

  this.bindEvents = function() {
    var self = this;

    this.$actions.on('change', function(e) {
      var state = $(e.target).val();
      $.publish('claim.status.change', {
        state: state
      })
    });

    this.$reasons.on('change', function(e) {
      var reason = self.$otherCheckbox.is(':checked');
      $.publish('claim.reasons.change', {
        reason: reason
      });
    });

    this.$refuseReasons.on('change', function(e) {
      var reason = self.$otherRefuseCheckbox.is(':checked');
      $.publish('claim.refuseReasons.change', {
        reason: reason
      })
    });

    $.subscribe('claim.reasons.change', function(e, data) {
      data.reason ? self.slider(true, self.$otherinput) : self.slider(false, self.$otherinput)
    });

    $.subscribe('claim.refuseReasons.change', function(e, data) {
      data.reason ? self.slider(true, self.$otherRefuseInput) : self.slider(false, self.$otherRefuseInput)
    });

    $.subscribe('claim.status.change', function(e, data) {
      var state = self.states[data.state]
      self.$form.is(function(idx, el) {
        self.slider(state.form, el)
      });

      self.$reasons.is(function(idx, el) {
        self.slider(state.reasons, el)
      });

      self.$refuseReasons.is(function(idx, el) {
        self.slider(state.refuseReasons, el)
      });
    });

  };

  this.init();
  return this;
};
