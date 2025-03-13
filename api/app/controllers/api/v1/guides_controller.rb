# ガイドアカウントを作成するためのコントローラー
class Api::V1::GuidesController < ApplicationController
  include Achievement
  before_action :require_login

  # ガイドアカウントを作成するメソッド
  def create
    # ガイドアカウントに必要な情報を取得

    # 重複メールチェック
    guides = Guide.where(email: params[:email])

    unless guides.empty?
      response = {
        duplicates: true
      }
      render json: json_render_v1(true, response)
      return
    end

    begin
      guide = Guide.new(email: params[:email], name: params[:name], memo: params[:memo], tel: params[:tel], address1: params[:address1], address2: params[:address2], addyear: params[:addyear])
      guide.save!

      # アカウント作成メールを送信
      CreateAccountNotifyMailer.creation_email(guide, nil).deliver_now

    # バリデーション外であればエラー表示
    rescue StandardError
      render json: json_render_v1(false)
      return
    end

    response = {
      duplicates: false
  }
    # アカウントが作成されたら成功表示
    render json: json_render_v1(true, response)
    # render json: json_render_v1(true)
  end

  # ガイド詳細の取得
  def index
    # 情報の取得
    guide = Guide.find(params[:id])

    # 存在しない場合はエラーを返す
    if guide.nil?
      render json: json_render_v1(false, status: 204)
      return
    end

    # 論理削除済みは一部の情報を返す
    if guide.is_invalid
      render json: json_render_v1(false, {
        guide: {
          name: guide.name,
          email: guide.email
        }
      })
      return
    end

    # 実績の取得
    response = {}
    response["guide"] = guide
    response["achievement"] = achievement(params[:id])

    render json: json_render_v1(true, response)
  end

  # ガイドアカウントの論理削除
  def destroy
    guides_delete = Guide.find_by(id: params[:id])
    guides_delete.update(is_invalid: true)

    # トークンの削除
    tokens = Token.where(guide_id: params[:id])
    tokens.destroy_all

    # アカウント削除の通知メール
    DeleteAccountNotifyMailer.delete_email(guides_delete).deliver_now

    render json: json_render_v1(true)
  end

  # 　ガイド情報の変更をする
  def update
    guide = Guide.find_by(id: params[:id])
    name = params[:name]
    email = params[:email]
    memo = params[:memo]
    tel = params[:tel]
    address1 = params[:address1]
    address2 = params[:address2]
    addyear = params[:addyear]

    # 重複メールチェック
    guides = Guide.where.not(id: params[:id]).where(email: email)

    unless guides.empty?
      response = {
        duplicates: true
      }
      render json: json_render_v1(true, response)
      return
    end

    # 更新処理
    ApplicationRecord.transaction do
      guide.update!(name: name) unless name.nil?
      guide.update!(email: email) unless email.nil?
      guide.update!(memo: memo) unless memo.nil?
      guide.update!(tel: tel) unless tel.nil?
      guide.update!(address1: address1) unless address1.nil?
      guide.update!(address2: address2) unless address2.nil?
      guide.update!(addyear: addyear) unless addyear.nil?
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
