class Micropost < ApplicationRecord
  belongs_to       :user
  has_one_attached :image
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message: "should be less than 5MB" }

  # 表示用のリサイズ済み画像を返す
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end
  
  def Micropost.including_replies(user_id)
  # Micropostsテーブルから、下記のいずれか条件の投稿を取得する
  #   自分がフォローしている人
  #   自分のマイクロポスト
  #   返信先が自分になっているマイクロポスト
  user = User.find(user_id)
  Micropost.where("user_id  IN (:following_ids)
                   OR user_id     =   :user_id
                   OR in_reply_to =   :user_id" , 
                   following_ids: user.following_ids , 
                   user_id: user_id)
                 
  end
end


