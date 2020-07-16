module DatadogSync
  class Dashboards < Core

    def all_boards
      client_with_200(:get_all_boards).fetch('dashboards')
    end

    def backup!
      all_boards.map do |board|
        Concurrent::Future.execute do
          id = board['id']
          get_and_write(id)
        end
      end
    end

    def get_and_write(id)
      write(jsondump(get_board(id)), filename(id))
    end

    def get_board(id)
      client_with_200(:get_board, id)
    end


    def restore!; end
  end
end
