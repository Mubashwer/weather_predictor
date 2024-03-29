require 'matrix'

class Regression
    MIN_ORDER =  1  # minimum degree for polynomial regression model
    MAX_ORDER = 10  # maximum degree for polynomial regression model

    include ActiveModel::Model
    # Supplied method which performs the regression
    def self.regress(x_data, y_data, degree)
        x_y_data = x_data.map { |x_i| (0..degree).map { |pow| (x_i**pow).to_f } }
        mx = Matrix[*x_y_data]
        my = Matrix.column_vector(y_data)
        @coefficients = ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
    end

    # Gives the coefficient of determination using original
    # and predicted y values
    def self.give_r_squared(given, predicted)
        given_mean = given.inject(&:+)/given.size.to_f
        ss_total = 0.0; ss_res = 0.0

        for i in 0..given.length-1
            ss_total += (given[i] - given_mean)**2
            ss_res += (given[i] - predicted[i])**2
        end
        r_squared = 1.0 - (ss_res/ss_total)
        if r_squared.nan?
            # When ss_total, r_squared = Float::NAN, but since ss_total = 0,
            # there is a perfect regression equation equal to 0, hence r2 = 1.0
            return 1.0
        else
            return r_squared
        end
    end

    # It produces an array of the predicted values using the
    # given x values and an equation
    def self.find_predicted_values(x_data, model)
        return x_data.map{|x| model.each_with_index.inject(0)\
            {|y,(coeff,pow)| y + ((x**pow) * coeff)}}
    end

    # This finds the appropriate polynomial equation for polynomial regression
    def self.find_polynomial_model(x_data, y_data, min_order, max_order)
        result = ""; r2_max = 0
        for degree in (min_order..max_order)
            model = regress(x_data, y_data, degree)
            r2 = give_r_squared(y_data, find_predicted_values(x_data, model))
            # The "degree" for which the polynomial has the highest R^2 value is chosen
            if (degree == min_order or (r2 >  r2_max))
                r2_max = r2
                result = model
            end
        end
        return {eq: result, r2: r2_max}
    end

    # Performs the polynomial [and linear] regression
    def self.polynomial_regression(x_data, y_data, x_array)
        model = find_polynomial_model(x_data, y_data, MIN_ORDER, MAX_ORDER)
        r2 = model[:r2]
        model = model[:eq]
        value = find_predicted_values(x_array,model)
        return {value: value, r2: r2}
    end


    # Performs the logarithmic regression
    def self.logarithmic_regression(x_data, y_data, x_array)
        # y = a*ln(x) + b; trasform x-data for logarithmic regression
        begin 
            ln_x_data = x_data.map{|i| Math.log(i)}
        rescue Math::DomainError
            #print "Cannot perform logarithmic regression on this data"
            return nil
        end

        model = regress(ln_x_data, y_data, 1)
        r2 = give_r_squared(y_data, find_predicted_values(ln_x_data, model))
        
        begin 
            value = find_predicted_values(x_array.map{|i| Math.log(i)},model)
        rescue Math::DomainError
            return nil
        end
        
        return {value: value, r2: r2} 
    end

    # Performs the exponential regression
    def self.exponential_regression(x_data, y_data, x_array)
        # y = a*e^bx => ln(y) = b*x + log(a); transform y-data for exp. reg.
        begin 
            ln_y_data = y_data.map{|y| Math.log(y)}
        rescue Math::DomainError
            #print "Cannot perform exponential regression on this data"
            return nil
        end
        model = regress(x_data, ln_y_data, 1)
        r2 = give_r_squared(ln_y_data, find_predicted_values(x_data, model))
        value = find_predicted_values(x_array,model).map{|i| Math.exp(i)}

        # error checking
        value.each do |v|
            return nil if v.to_f.nan?
        end

        return {value: value, r2: r2}
    end

    # Performs various regression and returns the value with the
    # best-fit equation for given x, and the r-squared
    def self.get_value(x_data, y_data, x_array)
        if(!x_data.any? or !y_data.any? or !x_array.any? or x_data.count != y_data.count or x_data.count < 2)
            return {value: nil, r2: nil}
        end

        r2 = nil; value = nil
        results = [polynomial_regression(x_data, y_data, x_array),\
                  exponential_regression(x_data, y_data, x_array),\
                  logarithmic_regression(x_data, y_data, x_array)\
                 ]
        results.each do |result|
            if result and result[:r2] and (r2.nil? or result[:r2] > r2) and result[:value]
					r2 = result[:r2]
					#result[:value] = result[:value].map{|v| v.to_f.nan? ? 0.0 : v}
                    value = result[:value]
            end
        end 
        return {value: value, r2: r2}
    end
    
end
