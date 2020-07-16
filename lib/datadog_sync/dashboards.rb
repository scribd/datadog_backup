module DatadogSync
  class Dashboards < Core
    def all_boards
      client_with_200(:get_all_boards).fetch('dashboards')
    end

    def backup!
      all_boards.map do |board|
        id = board['id']
        write(jsondump(get_board(id)), filename(id))
      end
    end

    def filename(id)
      File.join(output_dir, 'dashboards', id + '.json')
    end

    def get_board(id)
      client_with_200(:get_board, id)
    end

    def restore!; end
  end
end
