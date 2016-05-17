describe("Autocomplete", function() {

  var fixtureDom = $('<div/>').attr('id', 'autocomplete_wrapper'),
    selectObj = '<select class="autocomplete" name="claim[case_type_id]" id="claim_case_type_id">' +
    '<option value=""></option>' +
    '<option data-is-fixed-fee="true" value="1">Appeal against conviction</option>' +
    '<option data-is-fixed-fee="true" value="2">Appeal against sentence</option>' +
    '<option data-is-fixed-fee="true" value="3">Breach of Crown Court order</option>' +
    '<option data-is-fixed-fee="true" value="4">Committal for Sentence</option>' +
    '<option data-is-fixed-fee="true" value="5">Contempt</option>' +
    '<option data-is-fixed-fee="false" value="6">Cracked Trial</option>' +
    '<option data-is-fixed-fee="false" value="7">Cracked before retrial</option>' +
    '<option data-is-fixed-fee="false" value="8">Discontinuance</option>' +
    '<option data-is-fixed-fee="true" value="9">Elected cases not proceeded</option>' +
    '<option data-is-fixed-fee="false" value="10">Guilty plea</option>' +
    '<option data-is-fixed-fee="false" value="11">Retrial</option>' +
    '<option data-is-fixed-fee="false" value="12">Trial</option>' +
    '</select>';


  beforeEach(function() {
    fixtureDom.append(selectObj);
    $('body').append(fixtureDom);
  });

  describe('init', function() {

    var select, input, list;

    beforeEach(function() {
      select = fixtureDom.find('select.autocomplete');
      select.AutoComplete();
      input = fixtureDom.find('#claim_case_type_id_autocomplete');
      list = fixtureDom.find('ul');

    });
    it('should be defined', function() {
      expect(select).toBeDefined();
    });
    it('should create the awesomplete input and hidden ul', function() {
      expect(input.is(':visible')).toBe(true);
      expect(list.is(':visible')).toBe(false);
    });
    it('should hide the select', function() {
      expect(fixtureDom.find('#claim_case_type_id').is(':visible')).toBe(false);
    });

    describe('enter Trial text', function() {
      beforeEach(function() {
        fixtureDom.find('#claim_case_type_id_autocomplete').val('Trial').trigger('change');
      });
      it('should update the select', function() {
        expect(fixtureDom.find('select').find('option:selected').text()).toBe('Trial');
        $('#autocomplete_wrapper').remove();
      });
    });

  });

});