# 管理者アカウントを作成するためのコントローラー
class Api::V1::AdminsController < ApplicationController
  before_action :require_login

  # 　管理者アカウント作成のメソッド
  def create
    # 管理者アカウントに必要な情報を取得
    begin
      # 重複メールチェック
      admins = Admin.where(email: params[:email])

      unless admins.empty?
        response = {
          duplicates: true
        }
        render json: json_render_v1(true, response)
        return
      end

      password = create_temp_pass
      admin = Admin.new(email: params[:email], name: params[:name], password: password)
      admin.save!

      # アカウント作成メールを送信
      CreateAccountNotifyMailer.creation_email(admin, password).deliver_now

      # バリデーション外であればエラー表示
    rescue StandardError
      render json: json_render_v1(false)
      return
    end
    response = {
      duplicates: false
    }
    # アカウントが作成されたら成功表示
    render json: json_render_v1(true)
  end

  # 管理者情報を取得する
  def index
    # /meの場合、自身の情報を取得
    if params[:id] == "me"
      response = {}
      response["admin"] = @current_user
    else
      # IDから取得
      admin = Admin.find(params[:id])

      # 存在しない場合はエラーを返す
      if admin.nil?
        render json: json_render_v1(false, status: 204)
        return
      end

      # 論理削除済みは一部の情報を返す
      if admin.is_invalid
        render json: json_render_v1(false, {
          admin: {
            name: admin.name,
            email: admin.email
          }
        })
        return
      end

      # 実績の取得
      response = {}
      response["admin"] = admin

    end
    render json: json_render_v1(true, response)
  end

  # アカウントの論理削除
  def destroy
    begin
      # 削除対象を取得
      admins_delete = Admin.find_by(id: params[:id])

      # 自分自身のIDを指定した場合
      if admins_delete.id == @current_user.id
        render json: json_render_v1(false)
        return
      end

      # アカウントの論理削除
      admins_delete.update(is_invalid: true)

      # アカウント削除の通知メール
      DeleteAccountNotifyMailer.delete_email(admins_delete).deliver_now

    # 失敗時
    rescue StandardError
      render json: json_render_v1(false)
      return
    end

    render json: json_render_v1(true)
  end

  # 管理者情報の変更をする
  def update
    admin = Admin.find_by(id: params[:id])
    # 他の管理者のIDを指定した場合
    if admin.id != @current_user.id
      render json: json_render_v1(false, status: 403)
      return
    end

    # 自分自身の情報のみ変更
    name = params[:name]
    email = params[:email]
    password = params[:password]

    # 重複メールチェック
    admins = Admin.where.not(id: params[:id]).where(email: email)

    unless admins.empty?
      response = {
        duplicates: true
      }
      render json: json_render_v1(true, response)
      return
    end

    # 各情報を更新
    ApplicationRecord.transaction do
      admin.update!(name: name) unless name.nil?
      admin.update!(email: email) unless email.nil?
      admin.update!(password: password) unless password.nil?
    end
    response = {
      duplicates: false
    }
    render json: json_render_v1(true, response)
    nil

  # 失敗時
  rescue ActiveRecord::RecordInvalid
    render json: json_render_v1(false)
  end
end
