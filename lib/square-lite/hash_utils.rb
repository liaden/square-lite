module SquareLite
  module HashUtils
    refine Hash do
      def promote!(*cs, namespace: false, &block)
        ks.each do |k|
          next unless key?(k)

          v = delete(k)
          v = block.call(v) if block
          self.merge!(v)
        end
      end

      def promote(*ks, namespace: false, &block)
        self.dup.promote!(*ks)
      end

      def demote(*ks, to: nil, &block)
        self.dup.demote!(*ks, to: to, &block)
      end

      def demote!(*ks, to: nil)
        v = ks.reduce({}) do |acc, k|
          acc[k] = delete(k) if key?(k)
          acc
        end

        v = yield v if block_given?

        self[to] = v
      end

      # the assignment version of dig:
      #   walk path down hashes of hashses until key is not defined
      #   create hash of hashes for rest of the path
      #   assign value at the final location
      def bury(*path)
        value = block_given? ? block.call : path.pop
        last_key = path.pop

        hash = path.reduce(self) do |hash, k|
          hash[k] = {} unless hash.key?(k)
          hash[k]
        end

        hash[last_key] = value
      end
    end
  end
end
