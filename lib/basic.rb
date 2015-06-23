  module Basic
    protected
    
    def nCr(n,r)
      return 1 if n == r
      return n if r == 1
      return 1 if n == 0 
      nCr(n-1,r) + nCr(n-1,r-1)
    end

    def lim_fact(a, b)
      f = 1; for i in a..b; f *= i; end; f
    end
  end

