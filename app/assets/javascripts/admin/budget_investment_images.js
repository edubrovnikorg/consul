// Generated by CoffeeScript 1.12.6
(function() {
  "use strict";
  App.BudgetInvestmentImages = {
    save_image: function(event) {
      event.preventDefault();
      var selected_image = $('#js-investment-change-image')[0].value
      var budget_id = $('#save_image').data('budget-id');
      var investment_id = $('#save_image').data('investment-id');

      $.ajax({
        type: "PUT",
        url: `/admin/budgets/${budget_id}/budget_investments/${investment_id}`,
        data: { budget_investment: { image_id: selected_image } },
        success:(data) =>{
          window.location.reload();
        },
        error:(data) => {
          window.location.reload();
        }
      });
    },
    initialize: function() {
      $('#save_image').on({
        click: function(event) {
          App.BudgetInvestmentImages.save_image(event);
        }
      });
    },
  };
}).call(this);
