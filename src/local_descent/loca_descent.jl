using Printf
using LinearAlgebra

function f_test(x::Array{Float64,1})::Real
    return x[1]^2 + x[1]*x[2] + x[2]^2
end

function gradf_test(x::Array{Float64,1})::Array{Float64,1}
    return [2*x[1] + x[2], 2*x[2] + x[1]]
end

function strong_backtracking(f::Function, grad_f::Function, x::Array{Float64,1}, step_vec::Array{Float64,1}; alpha::Float64=5.0, beta::Float64=1e-4, sigma::Float64=0.1) 
    y0, g0     = f(x), grad_f(x)⋅step_vec
    y_prev     = NaN
    alpha_prev = 0
    alpha_low, alpha_high = NaN, NaN
    # bracket phase
    while true
        y = f(x + alpha*step_vec)
        if y > y0 + beta*alpha*g0 || (!isnan(y_prev) && y ≥ y_prev) 
            alpha_low, alpha_high = alpha_prev, alpha
            break 
        end
                
        g = grad_f(x + alpha*step_vec)⋅step_vec 
        if abs(g) ≤ -sigma*g0 # Gradient magnitude
            return alpha 
        elseif g ≥ 0
            alpha_low, alpha_high = alpha, alpha_prev
            break 
        end
        y_prev, alpha_prev, alpha = y, alpha, 2*alpha 
    end
    
    @printf("The initial interval: %6.3f %6.3f\n", alpha_low, alpha_high)

    # zoom phase
    y_low = f(x + alpha_low*step_vec)
    n = 0
    while n < 10 # Maximum iterations
        alpha = (alpha_low + alpha_high)/2
        y = f(x + alpha*step_vec)
        @printf("The interval: %6.3f %6.3f\n", alpha_low, alpha_high)
        if y > y0 + beta*alpha*g0 || y ≥ y_low #
            @printf("No sufficient decrease: %6.3f %6.3f %6.3f %6.3f\n", alpha, y, y0, y_low)
            alpha_high = alpha 
        else
            g = grad_f(x + alpha*step_vec)⋅step_vec
            if abs(g) ≤ -sigma*g0 # Gradient magnitude
                return alpha 
            elseif g*(alpha_high - alpha_low) ≥ 0
                alpha_high = alpha_low 
            end
            alpha_low = alpha 
        end
        n += 1
    end 
end

x0 = [1.0, 2.0]
d = -gradf_test(x0)
strong_backtracking(f_test, gradf_test, x0, d)