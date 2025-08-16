# frozen_string_literal: true

class OfferCodeDiscountComputingService
  # While computing it rejects the product if quantity of the product is greater
  # than the quantity left for the offer_code for e.g. Suppose seller adds a
  # universal offer code which has 4 quantity left and a user adds three products
  # in bundle - A[2], B[3], C[1] (product names with quantity) and applies the
  # offer code. Then offer code will be applied on A[2], B[0], C[1]. It skipped B
  # because quantity of B was greater than the limit left for the offer_code.
  # Taking some more examples
  #   => A[2], B[3], C[2] --> A[2], C[2]
  #   => A[2], C[3]       --> A[2]

  def initialize(code, products)
    @code = code
    @products = products
  end

  def process
    products_data = {}

    products.each do |uid, product_info|
      purchase_quantity = product_info[:quantity].to_i
      link = find_link(product_info[:permalink])
      offer_code = find_applicable_offer_code_for(link)

      next unless offer_code

      if eligible?(offer_code, purchase_quantity)
        track_usage(offer_code, purchase_quantity)
        products_data[uid] = { discount: offer_code.discount }
      else
        track_ineligibility(offer_code, purchase_quantity)
      end
    end

    {
      products_data:,
      error_code:
    }
  end

  private
    attr_reader :code, :products

    def links
      @_links ||= Link.visible
        .where(unique_permalink: products.values.map { it[:permalink] })
    end

    def find_link(permalink)
      @_links_by_permalink ||= links.index_by(&:unique_permalink)
      @_links_by_permalink[permalink]
    end

    def offer_codes
      return OfferCode.none if code.blank?

      @_offer_codes ||= OfferCode
        .includes(:products)
        .where(user_id: links.map(&:user_id), code:)
        .alive
    end

    def offer_codes_by_user_id
      @_offer_codes_by_user_id ||= offer_codes.index_by(&:user_id)
    end

    def find_applicable_offer_code_for(link)
      offer_code = offer_codes_by_user_id[link.user_id]
      offer_code&.applicable?(link) ? offer_code : nil
    end

    def eligible?(offer_code, purchase_quantity)
      return false if offer_code.inactive?
      return false unless meets_minimum_purchase_quantity?(offer_code, purchase_quantity)
      return false unless has_sufficient_times_of_use?(offer_code, purchase_quantity)

      true
    end

    def meets_minimum_purchase_quantity?(offer_code, purchase_quantity)
      offer_code.minimum_quantity.blank? ||
        purchase_quantity >= offer_code.minimum_quantity
    end

    def has_sufficient_times_of_use?(offer_code, purchase_quantity)
      offer_code.max_purchase_count.blank? ||
        remaining_times_of_use(offer_code) >= purchase_quantity
    end

    def remaining_times_of_use(offer_code)
      @remaining_times_of_use ||= {}
      @remaining_times_of_use[offer_code.id] ||= offer_code.quantity_left
    end

    def track_usage(offer_code, purchase_quantity)
      return if offer_code.max_purchase_count.blank?

      @remaining_times_of_use[offer_code.id] -= purchase_quantity
    end

    def track_ineligibility(offer_code, purchase_quantity)
      @product_level_ineligibilities ||= {}

      unless meets_minimum_purchase_quantity?(offer_code, purchase_quantity)
        @product_level_ineligibilities[:unmet_minimum_purchase_quantity] = true
      end

      unless has_sufficient_times_of_use?(offer_code, purchase_quantity)
        if @remaining_times_of_use[offer_code.id].positive?
          @product_level_ineligibilities[:insufficient_times_of_use] = true
        else
          @product_level_ineligibilities[:sold_out] = true
        end
      end
    end

    def error_code
      return :invalid_offer if offer_codes.blank?
      return :inactive if offer_codes.all?(&:inactive?)

      if @product_level_ineligibilities.blank?
        nil
      elsif @product_level_ineligibilities[:unmet_minimum_purchase_quantity]
        :insufficient_quantity
      elsif @product_level_ineligibilities[:insufficient_times_of_use]
        :exceeding_quantity
      elsif @product_level_ineligibilities[:sold_out]
        :sold_out
      end
    end
end
