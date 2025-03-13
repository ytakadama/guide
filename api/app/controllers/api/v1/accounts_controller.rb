# アカウント一覧を取得するコントローラーです

class Api::V1::AccountsController < ApplicationController
  before_action :require_login

  # アカウント一覧を取得
  def index
    # 条件の初期値を設定

    name = params[:name] || "" # 検索に名前があるかないか
    email = params[:email] || "" # 検索にメールがあるかないか
    include_invalid = params[:include_invalid] || false # 無効なユーザーを含むか

    # if(include_invalid == "true")  then
    #    include_invalid = true
    # end
    account_admins = Admin
                     .where("name LIKE ?", "%#{name}%")
                     .where("email LIKE ?", "%#{email}%")
                     .where(is_invalid: include_invalid)
    # .where(is_invalid: true)
    # account_guides = Guide
    #                 .where("name LIKE ?", "%#{name}%")
    #                 .where("email LIKE ?", "%#{email}%")
    #                 .where(is_invalid: [include_invalid, false])

    # SQLを作成
    sql = <<~"EOS"
      select
          a.*
          , (#{' '}
              SELECT
                  count(tours.id)#{' '}
              FROM
                  tour_guides#{' '}
                  INNER JOIN tours#{' '}
                      ON tours.id = tour_guides.tour_id#{' '}
              WHERE
                  tour_guides.guide_id = a.id#{' '}
                  and (tour_state_code = 32
                  or start_datetime < datetime())
          ) as gaidcount#{'     '}
      from
          guides a#{' '}
      where
          a.name LIKE "%#{name}%"#{' '}
          and a.email LIKE "%#{email}%"#{' '}
          and a.is_invalid = #{include_invalid}
    EOS

    puts("■■■■■■■■#{sql}")

    # sqlを実行し、取得結果をhashに変換
    # res = ActiveRecord::Base.connection.select_all(sql)
    # account_guides = res.rows
    # res = ActiveRecord::Base.connection.select_all(sql)
    account_guides = ActiveRecord::Base.connection.select_all(sql).to_a
    # res = Post.find_by_sql(sql)
    # account_guides = res.rows

    response = {
        admins: account_admins,
        guides: account_guides
    }
    # puts "sum=" + response
    #    response.each do |key,value|
    #      puts "#{key}は#{value}です。"
    #      end
    render json: json_render_v1(true, response)
  end
end
