require 'rails_helper'

RSpec.describe "posts", type: :system, js: true do
  describe "新規投稿ページ" do
    let(:user) { create(:user) }
    let(:post) { build(:post, user: user, members_count: 0) }
    let!(:members) { create_list(:member, 5) }

    before do
      login(user)
      visit new_post_path
    end

    describe "バリデーション成功" do
      it "トップページに遷移し, 投稿がMAPエリアとPOSTSエリアに表示されていること" do
        fill_in "post[title]", with: post.title
        fill_in "post[url]", with: "https://test.example.jp"
        check "post[member_ids][]", option: members[1].id
        check "post[member_ids][]", option: members[3].id
        fill_in "post[description]", with: "this is a description for test."

        fill_in "address", with: "東京駅"
        within ".search-field" do
          click_button "検索"
        end

        expect(page).to have_field("post[address]",
          with: "Tokyo Station, 1-chōme-9 Marunouchi, Chiyoda City, Tokyo 100-0005, Japan",
          wait: 3)

        attach_file "post[pictures][]",
        [
          "#{Rails.root}/spec/fixtures/512bytes_sample.png",
          "#{Rails.root}/spec/fixtures/1megabytes_sample.jpeg",
        ]

        click_on "投稿する"

        # 更新されたpostの値を取得
        post = Post.last

        expect(page).to have_current_path root_path
        within ".notice" do
          expect(page).to have_content "投稿を作成しました。"
        end

        visit root_path(anchor: "map-anchor")
        within ".posts-map-area" do
          expect(page).to have_css "div[title='marker-#{post.id}']"
        end

        within ".posts-area" do
          expect(page).to have_selector "img[src*='default_user']"
          expect(page).to have_link post.user.username
          expect(page).to have_link post.title
          expect(page).to have_content post.address
          post.members.each do |member|
            expect(page).to have_content member.name
          end
        end
      end
    end

    describe "バリデーション失敗" do
      it "投稿タイトル(場所・施設名)がnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: nil
        click_on "投稿する"

        expect(page).to have_content "場所・施設名は必須項目です"
      end

      it "投稿タイトル(場所・施設名)が空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: ""
        click_on "投稿する"

        expect(page).to have_content "場所・施設名は必須項目です"
      end

      it "投稿タイトル(場所・施設名)が空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: " "
        click_on "投稿する"

        expect(page).to have_content "場所・施設名は必須項目です"
      end

      it "住所が検索から入力されていない時, 適切なエラーメッセージが表示されること" do
        click_on "投稿する"

        expect(page).to have_content "住所は必須項目です"
      end

      it "投稿タイトル(場所・施設名)が31文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: "a" * 31
        click_on "投稿する"

        expect(page).to have_content "場所・施設名は30文字以内で入力してください"
      end

      it "関連URLが101文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[url]", with: "a" * 101
        click_on "投稿する"

        expect(page).to have_content "関連URLは100文字以内で入力してください"
      end

      it "説明が401文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[description]", with: "a" * 401
        click_on "投稿する"

        expect(page).to have_content "説明は400文字以内で入力してください"
      end

      it "画像のファイルサイズが5MB以下でない時, また画像が4枚以上アップロードされた時, ぞれぞれ適切なエラーメッセージが表示されること" do
        attach_file "post[pictures][]",
        [
          "#{Rails.root}/spec/fixtures/512bytes_sample.png",
          "#{Rails.root}/spec/fixtures/1megabytes_sample.jpeg",
          "#{Rails.root}/spec/fixtures/2megabytes_sample.png",
          "#{Rails.root}/spec/fixtures/6megabytes_sample.png",
        ]

        click_on "投稿する"

        expect(page).to have_content "画像のファイルサイズは5MB以下である必要があります"
        expect(page).to have_content "画像は3枚までアップロードできます。"
      end
    end

    describe "住所の検索" do
      context "検索結果が存在しない時" do
        it "検索結果が存在しないことを示すダイアログが表示されること" do
          page.accept_confirm("該当する結果がありませんでした：INVALID_REQUEST") do
            within ".search-field" do
              click_button "検索"
            end
          end
        end
      end

      context "検索結果が存在する時" do
        it "住所の入力フィールドに検索結果の住所が入力されること" do
          fill_in "address", with: "東京駅"
          within ".search-field" do
            click_button "検索"
          end

          expect(page).to have_field("post[address]",
            with: "Tokyo Station, 1-chōme-9 Marunouchi, Chiyoda City, Tokyo 100-0005, Japan",
            wait: 3)
        end
      end
    end

    it "キャンセルをクリックした時, トップページに遷移すること" do
      click_link "キャンセル"

      expect(page).to have_current_path root_path
    end
  end

  describe "投稿編集ページ" do
    let(:user) { create(:user) }
    let!(:members) { create_list(:member, 5) }
    let!(:post) do
      create(:post,
        url: "https://test.example.jp",
        description: "this is a description for test",
        members_count: 0,
        members: [members[1], members[3]],
        address: "Tokyo Station, 1-chōme-9 Marunouchi, Chiyoda City, Tokyo 100-0005, Japan",
        latitude: 35.6812,
        longitude: 139.767,
        user: user,
        user_id: user.id,
        pictures: [
          {
            io: File.open("#{Rails.root}/spec/fixtures/512bytes_sample.png"), filename: "512bytes_sample.png",
            content_type: "image/png",
          },
          {
            io: File.open("#{Rails.root}/spec/fixtures/1megabytes_sample.jpeg"), filename: "1megabytes_sample.jpeg",
            content_type: "image/jpeg",
          },
        ])
    end

    before do
      login(user)
      visit edit_post_path(post)
    end

    it "投稿タイトル(場所・施設名), 関連URL, 関係するメンバー, 説明, 住所の値が各入力フィールドに入力されていること" do
      within ".post-form" do
        expect(page).to have_field "post[title]", with: post.title
        expect(page).to have_field "post[url]", with: post.url
        expect(page).to have_checked_field "post_member_ids_#{post.member_ids[0]}"
        expect(page).to have_checked_field "post_member_ids_#{post.member_ids[1]}"
        expect(page).to have_field "post[description]", with: post.description
        expect(page).to have_field "post[address]", with: post.address
      end
    end

    describe "バリデーション成功" do
      it "ユーザー詳細ページに遷移し, 投稿を編集した旨のメッセージが表示されること" do
        check "post[member_ids][]", option: members[0].id

        click_on "更新する"

        post = Post.last

        expect(page).to have_current_path user_path(post.user)
        within ".notice" do
          expect(page).to have_content "投稿を更新しました。"
        end

        within ".posts-area" do
          post.members.each do |member|
            expect(page).to have_content member.name
          end
        end
      end
    end

    describe "バリデーション失敗" do
      it "投稿タイトル(場所・施設名)がnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: nil
        click_on "更新する"

        expect(page).to have_content "場所・施設名は必須項目です"
      end

      it "投稿タイトル(場所・施設名)が空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: ""
        click_on "更新する"

        expect(page).to have_content "場所・施設名は必須項目です"
      end

      it "投稿タイトル(場所・施設名)が空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: " "
        click_on "更新する"

        expect(page).to have_content "場所・施設名は必須項目です"
      end

      it "投稿タイトルが31文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[title]", with: "a" * 31
        click_on "更新する"

        expect(page).to have_content "場所・施設名は30文字以内で入力してください"
      end

      it "関連URLが101文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[url]", with: "a" * 101
        click_on "更新する"

        expect(page).to have_content "関連URLは100文字以内で入力してください"
      end

      it "説明が401文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "post[description]", with: "a" * 401
        click_on "更新する"

        expect(page).to have_content "説明は400文字以内で入力してください"
      end

      it "画像のファイルサイズが5MB以下でない時, また画像が4枚以上アップロードされた時, ぞれぞれ適切なエラーメッセージが表示されること" do
        attach_file "post[pictures][]",
        [
          "#{Rails.root}/spec/fixtures/512bytes_sample.png",
          "#{Rails.root}/spec/fixtures/1megabytes_sample.jpeg",
          "#{Rails.root}/spec/fixtures/2megabytes_sample.png",
          "#{Rails.root}/spec/fixtures/6megabytes_sample.png",
        ]

        click_on "更新する"

        expect(page).to have_content "画像のファイルサイズは5MB以下である必要があります"
        expect(page).to have_content "画像は3枚までアップロードできます。"
      end
    end

    describe "住所の検索" do
      context "検索結果が存在しない時" do
        it "検索結果が存在しないことを示すダイアログが表示されること" do
          page.accept_confirm("該当する結果がありませんでした：INVALID_REQUEST") do
            within ".search-field" do
              click_button "検索"
            end
          end
        end
      end

      context "検索結果が存在する時" do
        it "住所の入力フィールドに検索結果の住所が入力されること" do
          fill_in "address", with: "東京駅"
          within ".search-field" do
            click_button "検索"
          end

          expect(page).to have_field("post[address]",
            with: "Tokyo Station, 1-chōme-9 Marunouchi, Chiyoda City, Tokyo 100-0005, Japan",
            wait: 3)
        end
      end
    end

    it "キャンセルをクリックした時, ユーザー詳細ページに遷移すること" do
      click_link "キャンセル"

      expect(page).to have_current_path user_path(user)
    end
  end

  describe "投稿詳細ページ" do
    let(:user) { create(:user, :with_icon) }
    let(:other_user_1) { create(:user) }
    let(:other_user_2) { create(:user) }
    let(:post) { create(:post, user: user) }

    before do
      post.favorited_users << other_user_1
      post.favorited_users << other_user_2

      visit post_path(post)
    end

    describe "表示" do
      it "投稿タイトル(場所・施設名), 住所, 投稿ユーザー名, 投稿日, いいね数が表示されていること" do
        within ".title" do
          expect(page).to have_content post.title
        end
        within ".address" do
          expect(page).to have_content post.address
        end
        within ".post-area" do
          expect(page).to have_content post.user.username
          within ".created-at" do
            expect(page).to have_content post.created_at.strftime("%Y年%m月%d日 %H:%M")
          end
        end
        within ".favorite-area" do
          expect(page).to have_content post.favorites.count
        end
      end

      describe "関連URL" do
        context "投稿にて関連URLを入力していない場合" do
          it "関連URLが表示されていないこと" do
            within find(".related-url", visible: false) do
              expect(page).to have_content ""
            end
          end
        end

        context "投稿にて関連URLを入力した場合" do
          let(:post) { create(:post, url: "https://test.example.jp") }

          before do
            visit post_path(post)
          end

          it "関連URLが表示されていること" do
            within ".related-url" do
              expect(page).to have_content post.url
            end
          end
        end
      end

      describe "説明" do
        context "投稿にて説明を入力していない場合" do
          it "説明が表示されていないこと" do
            within find(".description", visible: false) do
              expect(page).to have_content ""
            end
          end
        end

        context "投稿にて説明を入力した場合" do
          let(:post) { create(:post, description: "this is a description for test.") }

          before do
            visit post_path(post)
          end

          it "説明が表示されていること" do
            within ".description" do
              expect(page).to have_content post.description
            end
          end
        end
      end

      describe "関連メンバー" do
        context "投稿にて関連メンバーを選択していない場合" do
          before do
            post.members.destroy_all
            visit post_path(post)
          end

          it "関連メンバーが表示されていないこと" do
            within ".members" do
              expect(page).to have_content ""
            end
          end
        end

        context "投稿にて関連メンバーを選択した場合" do
          it "関連メンバーが表示されていること" do
            within ".members" do
              post.members.each do |member|
                expect(page).to have_content member.name
              end
            end
          end
        end
      end

      describe "ユーザーアイコン" do
        context "投稿ユーザーがアイコンを設定していない場合" do
          let(:user) { create(:user) }

          before do
            visit post_path(post)
          end

          it "デフォルトアイコンが表示されていること" do
            within ".post-area" do
              expect(page).to have_selector "img[src*='default_user'][width='50'][height='50']"
            end
          end
        end

        context "投稿ユーザーがアイコンを設定している場合" do
          it "設定したアイコンが表示されていること" do
            within ".post-area" do
              expect(page).to have_selector "img[src*='#{user.icon.filename}'][width='50'][height='50']"
            end
          end
        end
      end

      describe "投稿画像" do
        context "投稿にて画像をアップロードしていない場合" do
          it "デフォルト画像が表示されていること" do
            within ".pictures" do
              expect(page).to have_selector "img[src*='default_post']"
            end
          end
        end

        context "投稿にて画像をアップロードした場合" do
          let(:post) do
            create(:post,
              pictures: [
                {
                  io: File.open("#{Rails.root}/spec/fixtures/512bytes_sample.png"), filename: "512bytes_sample.png",
                  content_type: "image/png",
                },
                {
                  io: File.open("#{Rails.root}/spec/fixtures/1megabytes_sample.jpeg"), filename: "1megabytes_sample.jpeg",
                  content_type: "image/jpeg",
                },
              ])
          end

          before do
            visit post_path(post)
          end

          it "アップロードしたすべての画像が表示されていること" do
            within ".pictures" do
              post.pictures.each do |picture|
                expect(page).to have_selector "img[src*='#{picture.filename}']"
              end
            end
          end
        end
      end

      describe "マップ" do
        it "マーカーピンが表示されていること" do
          within "#post-map" do
            expect(page).to have_css "div[title='marker-#{post.id}']"
          end
        end

        it "マーカーピンをクリックするとinfowindowが表示されること" do
          within "#post-map" do
            find("div[title='marker-#{post.id}']").click
          end

          within ".address-in-map" do
            expect(page).to have_content post.address
          end
        end
      end

      describe "編集及び削除リンク" do
        context "投稿ユーザーとログインユーザーが一致していない場合" do
          let(:post) { create(:post) }

          before do
            post_path(post)
          end

          it "編集及び削除リンクが表示されていないこと" do
            within ".post-details-links" do
              expect(page).to_not have_link "編集"
              expect(page).to_not have_link "削除"
            end
          end
        end

        context "投稿ユーザーとログインユーザーが一致している場合" do
          before do
            login(user)
            visit post_path(post)
          end

          it "編集及び削除リンクが表示されていること" do
            within ".post-details-links" do
              expect(page).to have_link "編集"
              expect(page).to have_link "削除"
            end
          end
        end
      end
    end

    describe "リンク" do
      context "投稿ユーザーがアイコンを設定していない場合" do
        let(:user) { create(:user) }

        before do
          visit post_path(post)
        end

        it "デフォルトアイコンをクリックした時, ユーザー詳細ページに遷移すること" do
          within ".post-area" do
            find("img[src*='default_user']").click
          end

          expect(page).to have_current_path user_path(post.user)
        end
      end

      context "投稿ユーザーがアイコンを設定している場合" do
        it "設定したアイコンをクリックした時, ユーザー詳細ページに遷移すること" do
          within ".post-area" do
            find("img[src*='#{user.icon.filename}']").click
          end

          expect(page).to have_current_path user_path(post.user)
        end
      end
    end

    describe "いいね" do
      describe "ログイン前" do
        it "いいねアイコンをクリックすると, ログインページに遷移し, 適切なメッセージが表示されること" do
          within ".favorite-area" do
            find("svg[data-icon='heart']").click
          end

          expect(page).to have_current_path new_user_session_path
          within ".alert" do
            expect(page).to have_content "ログインが必要です。"
          end
        end
      end

      describe "ログイン後" do
        before do
          login(user)
          visit post_path(post)
        end

        context "未いいね状態でいいねアイコンをクリックした時" do
          it "アイコンが変化するとともに, いいねの表示が1増えること" do
            initial_count = post.favorites.count

            within "#favorite-post-#{post.id}" do
              find(".heart").click

              expect(page).to have_css ".filled-heart"
              expect(page).to have_link "#{initial_count + 1}"
            end
          end
        end

        context "いいね済み状態でいいねアイコンをクリックした時" do
          before do
            post.favorited_users << user
            visit post_path(post)
          end

          it "アイコンが変化するとともに, いいねの表示が1減ること" do
            initial_count = post.favorites.count

            within "#favorite-post-#{post.id}" do
              find(".filled-heart").click

              expect(page).to have_css ".heart"
              expect(page).to have_link "#{initial_count - 1}"
            end
          end
        end
      end

      it "いいね数をクリックすると, いいねユーザー一覧ページに遷移すること" do
        within "#favorite-post-#{post.id}" do
          find(".likes").click
        end

        expect(page).to have_current_path post_favorite_path(post)
      end
    end

    describe "レビュー" do
      let!(:comment_from_other_user_1) do
        create(:comment,
          user_id: other_user_1.id,
          post_id: post.id,
          created_at: 1.day.ago)
      end
      let!(:comment_from_other_user_2) do
        create(:comment,
          user_id: other_user_2.id,
          post_id: post.id,
          rate: 4,
          comment: "this is a comment for test.")
      end

      before do
        login(user)
        visit post_path(post)
      end

      describe "表示" do
        it "レビュー件数及び平均評価が適切に表示されていること" do
          within "#comment-count" do
            expect(page).to have_content "2件"

            average_rate = (4 + 5) / 2.0
            expect(page).to have_content average_rate.round(1)
            expect(page).to have_css ".star5-average-rating[data-rate='#{average_rate.round(1)}']"
          end
        end

        it "ユーザーアイコン, ユーザー名, 作成日, レビュー内容が適切に表示されていること" do
          within all(".comment")[0] do
            within ".created-at" do
              expect(page).to have_content comment_from_other_user_1.created_at.strftime("%Y年%m月%d日 %H:%M")
            end
            within ".username" do
              expect(page).to have_content comment_from_other_user_1.user.username
            end
            expect(page).to have_selector "img[src*='default_user']"
            within ".star5-rating" do
              expect(page).to have_css ".star5-rating-front[style='width: 100%;']"
              expect(page).to have_css ".star5-rating-back"
            end
            within ".body" do
              expect(page).to have_content comment_from_other_user_1.comment
            end
          end

          within all(".comment")[1] do
            within ".created-at" do
              expect(page).to have_content comment_from_other_user_2.created_at.strftime("%Y年%m月%d日 %H:%M")
            end
            within ".username" do
              expect(page).to have_content comment_from_other_user_2.user.username
            end
            expect(page).to have_selector "img[src*='default_user']"
            within ".star5-rating" do
              expect(page).to have_css ".star5-rating-front[style='width: 80%;']"
              expect(page).to have_css ".star5-rating-back"
            end
            within ".body" do
              expect(page).to have_content comment_from_other_user_2.comment
            end
          end
        end
      end

      describe "リンク" do
        it "アイコンをクリックすると, ユーザー詳細ページに遷移すること" do
          within all(".comment")[0] do
            find("img[src*='default_user']").click
          end

          expect(page).to have_current_path user_path(comment_from_other_user_1.user)
        end

        it "ユーザー名をクリックすると, ユーザー詳細ページに遷移すること" do
          within all(".comment")[0] do
            click_link comment_from_other_user_1.user.username
          end

          expect(page).to have_current_path user_path(comment_from_other_user_1.user)
        end
      end

      describe "レビュー作成" do
        describe "バリデーション成功" do
          it "作成したレビューが適切に表示されること" do
            label = find("label", text: "普通")
            label.click
            expect(page).to have_checked_field "star3", visible: false

            fill_in "comment[comment]", with: "this is a review for test."

            within ".comment-area" do
              click_on "レビューする"
            end

            # Ajaxリクエストの完了を待機
            expect(page).to have_selector(".comment", count: 3, wait: 3)

            comment = Comment.last

            within "#comment-count" do
              expect(page).to have_content "3件"

              average_rate = (4 + 5 + 3) / 3.0
              expect(page).to have_content average_rate.round(1)
              expect(page).to have_css ".star5-average-rating[data-rate='#{average_rate.round(1)}']"
            end

            within all(".comment")[2] do
              within ".created-at" do
                expect(page).to have_content comment.created_at.strftime("%Y年%m月%d日 %H:%M")
              end
              within ".username" do
                expect(page).to have_content comment.user.username
              end
              expect(page).to have_selector "img[src*='#{comment.user.icon.filename}']"
              within ".star5-rating" do
                expect(page).to have_css ".star5-rating-front[style='width: 60%;']"
                expect(page).to have_css ".star5-rating-back"
              end
              within ".body" do
                expect(page).to have_content comment.comment
              end
            end
          end
        end

        describe "バリデーション失敗" do
          it "評価が選択されていない時, 星評価の選択を促すダイアログが表示されること" do
            page.accept_confirm("星評価を選択してください") do
              within ".comment-area" do
                click_on "レビューする"
              end
            end

            expect(page).to have_current_path post_path(post)
          end

          it "レビュー内容が201文字以上の時, ダイアログにてエラーメッセージが表示されること" do
            label = find("label", text: "普通")
            label.click
            fill_in "comment[comment]", with: "a" * 201

            expect(page).to have_checked_field "star3", visible: false

            page.accept_confirm("レビューは200文字以内で入力してください") do
              within ".comment-area" do
                click_on "レビューする"
              end
            end
            expect(page).to have_current_path post_path(post)
          end

          it "既にレビューをしている時, レビュー済みであることを示すダイアログが表示されること" do
            label = find("label", text: "普通")
            label.click
            expect(page).to have_checked_field "star3", visible: false

            fill_in "comment[comment]", with: "this is a review for test."

            within ".comment-area" do
              click_on "レビューする"
            end

            expect(page).to have_selector(".comment", count: 3, wait: 3)

            label = find("label", text: "最高")
            label.click

            expect(page).to have_checked_field "star1", visible: false

            page.accept_confirm("あなたは既にレビューしています") do
              within ".comment-area" do
                click_on "レビューする"
              end
            end
            expect(page).to have_current_path post_path(post)
          end
        end

        describe "レビューの削除" do
          before do
            label = find("label", text: "普通")
            label.click
            fill_in "comment[comment]", with: "this is a review for test."

            within ".comment-area" do
              click_on "レビューする"
            end
          end

          it "ログインユーザーのレビューに削除アイコンが表示されていること" do
            expect(page).to have_selector(".comment", count: 3, wait: 3)

            within all(".comment")[2] do
              expect(page).to have_css ".trash-can"
            end
          end

          describe "削除アイコンクリック時" do
            it "確認ダイアログが表示され, キャンセルをクリックした場合, レビューは削除されないこと" do
              expect(page).to have_selector(".comment", count: 3, wait: 3)

              within all(".comment")[2] do
                page.dismiss_confirm("レビューを削除しますか？") do
                  find(".trash-can").click
                end
              end

              expect(page).to have_selector(".comment", count: 3, wait: 3)

              within "#comment-count" do
                expect(page).to have_content "3件"

                average_rate = (4 + 5 + 3) / 3.0
                expect(page).to have_content average_rate.round(1)
                expect(page).to have_css ".star5-average-rating[data-rate='#{average_rate.round(1)}']"
              end
            end

            it "確認ダイアログが表示され, OKをクリックした場合, レビューが削除されること" do
              expect(page).to have_selector(".comment", count: 3, wait: 3)

              within all(".comment")[2] do
                page.accept_confirm("レビューを削除しますか？") do
                  find(".trash-can").click
                end
              end

              expect(page).to have_selector(".comment", count: 2, wait: 3)

              within "#comment-count" do
                expect(page).to have_content "2件"

                average_rate = (4 + 5) / 2.0
                expect(page).to have_content average_rate.round(1)
                expect(page).to have_css ".star5-average-rating[data-rate='#{average_rate.round(1)}']"
              end
            end
          end
        end

        it "ログイン前にレビューするボタンをクリックすると, ログインページに遷移し, 適切なメッセージが表示されること" do
          logout(user)
          visit post_path(post)

          within ".comment-area" do
            click_on "レビューする"
          end

          expect(page).to have_current_path new_user_session_path
          within ".alert" do
            expect(page).to have_content "ログインが必要です。"
          end
        end
      end
    end

    describe "ナビゲーションリンク" do
      it "TOPをクリックするとトップページに遷移すること" do
        within ".navigation-link" do
          click_link "TOP"
        end
        expect(page).to have_current_path root_path
      end

      it "ナビゲーションリンクに投稿タイトル(場所・施設名)が表示されていること" do
        within ".navigation-link" do
          expect(page).to have_content post.title
        end
      end
    end
  end

  describe "いいねユーザー一覧ページ" do
    let(:user) { create(:user, :with_icon) }
    let(:other_user_1) { create(:user) }
    let(:other_user_2) { create(:user) }
    let(:post) { create(:post, user: user) }

    describe "投稿にいいねが付いている場合" do
      before do
        post.favorited_users << user
        post.favorited_users << other_user_1
        post.favorited_users << other_user_2

        user.following_users << other_user_1

        other_user_1.posts << create_list(:post, 2)
        other_user_2.posts << create_list(:post, 3)

        user.members << create_list(:member, 5)

        login(user)
        visit post_favorite_path(post)
      end

      describe "ユーザーリスト内の表示" do
        it "ユーザーアイコン, ユーザー名, 投稿数, 推しメン, フォローボタンが適切に表示されていること" do
          within all(".user")[0] do
            within ".profile-area-top" do
              expect(page).to have_selector "img[src*='#{user.icon.filename}'][width='45'][height='45']"
              expect(page).to have_content user.username
              expect(page).to have_content "投稿数 #{user.posts.count}"
              expect(page).to_not have_css ".btn-unfollow"
              expect(page).to_not have_css ".btn-follow"
            end

            within ".profile-area-oshi" do
              expect(page).to_not have_content "未設定"
              user.members.each do |member|
                expect(page).to have_content member.name
              end
            end
          end

          within all(".user")[1] do
            within ".profile-area-top" do
              expect(page).to have_selector "img[src*='default_user'][width='45'][height='45']"
              expect(page).to have_content other_user_1.username
              expect(page).to have_content "投稿数 #{other_user_1.posts.count}"
              expect(page).to have_css ".btn-unfollow"
              expect(page).to_not have_css ".btn-follow"
            end

            within ".profile-area-oshi" do
              expect(page).to have_content "未設定"
              other_user_1.members.each do |member|
                expect(page).to_not have_content member.name
              end
            end
          end

          within all(".user")[2] do
            within ".profile-area-top" do
              expect(page).to have_selector "img[src*='default_user'][width='45'][height='45']"
              expect(page).to have_content other_user_2.username
              expect(page).to have_content "投稿数 #{other_user_2.posts.count}"
              expect(page).to_not have_css ".btn-unfollow"
              expect(page).to have_css ".btn-follow"
            end

            within ".profile-area-oshi" do
              expect(page).to have_content "未設定"
              other_user_2.members.each do |member|
                expect(page).to_not have_content member.name
              end
            end
          end
        end
      end

      describe "ユーザーリスト内のリンク" do
        it "ユーザーアイコンをクリックするとユーザー詳細ページに遷移すること" do
          within all(".user")[0] do
            within ".profile-area-top" do
              find("img[src*='#{user.icon.filename}']").click
            end
          end
          expect(page).to have_current_path user_path(user)
        end

        it "ユーザー名をクリックするとユーザー詳細ページに遷移すること" do
          within all(".user")[0] do
            within ".profile-area-top" do
              click_link user.username
            end
          end
          expect(page).to have_current_path user_path(user)
        end
      end

      describe "フォローボタン" do
        it "フォロー中と表示されているボタンをクリックするとフォローが外れ, ボタンの表示がフォローになること" do
          initial_count = user.following_users.count

          within all(".user")[1] do
            within ".profile-area-top" do
              find(".btn-unfollow").click
            end
          end

          # クリックして要素の状態を更新した後に検証
          within all(".user")[1] do
            within ".profile-area-top" do
              expect(page).to have_css ".btn-follow"
              expect(page).to_not have_css ".btn-unfollow"
            end
          end

          expect(user.following_users.count).to eq initial_count - 1
        end

        it "フォローと表示されているボタンをクリックするとフォローして, ボタンの表示がフォロー中になること" do
          initial_count = user.following_users.count

          within all(".user")[2] do
            within ".profile-area-top" do
              find(".btn-follow").click
            end
          end

          within all(".user")[2] do
            within ".profile-area-top" do
              expect(page).to_not have_css ".btn-follow"
              expect(page).to have_css ".btn-unfollow"
            end
          end

          expect(user.following_users.count).to eq initial_count + 1
        end
      end
    end

    describe "投稿にいいねが付いていない場合" do
      before do
        visit post_favorite_path(post)
      end

      it "いいねしたユーザーがいない旨の表示がされていること" do
        within ".not-applicable" do
          expect(page).to have_content "まだいいねしたユーザーはいません。"
        end
      end
    end

    describe "ナビゲーションリンク" do
      before do
        visit post_favorite_path(post)
      end

      it "TOPをクリックするとトップページに遷移すること" do
        within ".navigation-link" do
          click_link "TOP"
        end
        expect(page).to have_current_path root_path
      end

      it "ナビゲーションリンクに投稿タイトル(場所・施設名)が表示されていること" do
        within ".navigation-link" do
          expect(page).to have_content post.title
        end
      end

      it "投稿タイトル(場所・施設名)をクリックすると投稿詳細ページに遷移すること" do
        within ".navigation-link" do
          click_link post.title
        end
        expect(page).to have_current_path post_path(post)
      end
    end
  end
end
