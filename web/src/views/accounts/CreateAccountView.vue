<template>
  <div id="create-account-page">
    <p class="create-info" v-if="$route.query.status == '200'">
      {{ $t("pages.accounts.create.message.true") }}
    </p>
    <p class="create-info" v-if="$route.query.status == '500'">
      {{ $t("pages.accounts.create.message.false") }}
    </p>
    <h1>{{ $t("pages.accounts.create.title") }}</h1>
    <p>
      {{ $t("pages.accounts.create.detail") }}
    </p>
    <div class="form-frame">
      <form @submit.prevent="create" class="form-main">
        <div id="radio">
          <input
            id="admin_radio"
            type="radio"
            name="class"
            value="admin"
            v-model="isAdminChecking"
          /><label for="admin_radio">{{ $t("account.admin") }}</label>
          <input
            type="radio"
            name="class"
            value="guide"
            id="guide_radio"
            v-model="isAdminChecking"
          /><label for="guide_radio">{{ $t("account.guide") }}</label>
        </div>
        <div class="form-tabel">
          <label for="name">名前&emsp;<font color="red">※必須</font>：</label
          ><input type="text" placeholder="name" id="name" maxlength="50" />
          <label for="email"
            >メールアドレス&emsp;<font color="red">※必須</font>：</label
          ><input type="text" placeholder="email" id="email" maxlength="300" />

          <label for="tel" v-if="isAdminChecking === 'guide'">TEL：</label
          ><input
            type="text"
            placeholder="tel"
            id="tel"
            v-if="isAdminChecking === 'guide'"
            maxlength="15"
          />

          <label for="address1" v-if="isAdminChecking === 'guide'"
            >住所(市区町村)：</label
          ><input
            type="text"
            placeholder="address1"
            id="address1"
            v-if="isAdminChecking === 'guide'"
            maxlength="100"
          />

          <label for="address2" v-if="isAdminChecking === 'guide'"
            >住所(それ以降)：</label
          ><input
            type="text"
            placeholder="address2"
            id="address2"
            v-if="isAdminChecking === 'guide'"
            maxlength="100"
          />

          <label for="addyear" v-if="isAdminChecking === 'guide'"
            >登録年：</label
          ><input
            type="number"
            placeholder="addyear"
            id="addyear"
            v-if="isAdminChecking === 'guide'"
          />

          <label for="memo" v-if="isAdminChecking === 'guide'">{{
            $t("label.memo")
          }}</label
          ><textarea
            cols="30"
            rows="5"
            name="memo"
            id="memo"
            v-if="isAdminChecking === 'guide'"
          >
          </textarea>
        </div>
        <br />
        <div class="form-button-frame">
          <button class="" @click="$router.back()">
            {{ $t("button.cancel") }}
          </button>
          <button type="submit" class="button-green">
            {{ $t("button.send") }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import api from "@/mixins/api";

export default {
  data() {
    return {
      test: "",
      isAdminChecking: "admin",
    };
  },
  created() {},
  methods: {
    form_reset() {
      const forms = document.getElementsByTagName("input");
      for (let i = 0; i < forms.length; i += 1) {
        forms[i].value = null;
      }
    },
    async create() {
      let classpath = "/api/v1/admins";
      const object = {
        name: document.getElementById("name").value,
        email: document.getElementById("email").value,
      };
      if (document.getElementById("name").value === "") {
        alert("名前を入力してください");
        return;
      }
      if (document.getElementById("email").value === "") {
        alert("メールアドレスを入力してください");
        return;
      }
      const email = document.getElementById("email").value;
      if (!email.match(/.+@.+\..+/)) {
        alert("メールアドレスのフォーマットが不正です");
        return;
      }

      if (
        document.querySelector("input[name=class]:checked").value === "guide"
      ) {
        classpath = "/api/v1/guides";

        // 電話番号チェック
        // 電話番号の正規表現（固定電話、携帯、フリーダイヤル、IP電話を考慮）
        const tel = document.getElementById("tel").value;
        // const regexp = /^0\d{1,3}-\d{2,4}-\d{3,4}$/;
        const regex =
          /^(0[5-9]0[-(]?[0-9]{4}[-)]?[0-9]{4}|0120[-]?\d{1,3}[-]?\d{4}|050[-]?\d{4}[-]?\d{4}|0[1-9][-]?\d{1,4}[-]?\d{1,4}[-]?\d{4})*$/;
        if (tel !== "" && !regex.test(tel)) {
          alert("電話番号のフォーマットが不正です");
          return;
        }

        // 登録年：
        const addyear = document.getElementById("addyear").value;
        if (addyear !== "" && addyear.length !== 4) {
          alert("登録年は４桁で入力してください");
          return;
        }

        // めも
        const memo = document.getElementById("memo").value;
        if (memo !== "" && memo.length > 200) {
          alert("メモは200文字以内で入力してください");
        }

        object.memo = document.getElementById("memo").value;
        object.tel = document.getElementById("tel").value;
        object.address1 = document.getElementById("address1").value;
        object.address2 = document.getElementById("address2").value;
        object.addyear = document.getElementById("addyear").value;
      }
      try {
        // ロード中にする
        this.$emit("SendLoadComplete", false);

        // アカウント作成情報を送信
        const response = await api.post(classpath, object, this.$router.push);

        // API完了
        /* alert(`重複チェック=${response.duplicates}`);
        alert(`重複チェック2=${response.data}`);
        alert(`重複チェック3=${response.data.duplicates}`); */

        if (response.data.duplicates) {
          alert("メールアドレスが重複しています。削除済みも確認してください");
        } else if (response.status === "success") {
          // 成功
          alert(this.$t("pages.accounts.create.message.true"));
          this.$router.push("/accounts");
        } else {
          // 失敗
          this.$router.push("?status=500").catch(() => {});
        }
        /* } else {
          const response = await api.post(
            "/api/v1/admins",
            {
              name: document.getElementById("name").value,
              email: document.getElementById("email").value,
            },
            this.$router.push
          );



          // API完了
          if (response.status === "success") {
            // 成功
            this.form_reset();
            this.$router.push("/tourslist");
          } else {
            // 失敗
            this.$router.push("?status=500").catch(() => {});
          }
        } */
      } catch {
        this.error = 500;
      } finally {
        this.$emit("SendLoadComplete", true);
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.create-account-page {
  max-width: 100%;
  position: relative;
}

.create-info {
  background-color: var(--color-light-gray);
  border-radius: 1em;
  text-align: center;
  padding: 2em;
}

.form-frame {
  margin: 0 auto;
  width: 100%;
  max-width: 640px;
  background-color: var(--color-light-gray);
  box-sizing: border-box;
  border-radius: 0.5em;
}

.form-tabel {
  width: 80%;
  display: inline-grid;
  grid-template-columns: auto 1fr;
  grid-row-gap: 0.5em;
}

.form-tabel label {
  height: 100%;
  display: flex;
  justify-content: right;
  align-items: center;
}

.form-main {
  padding: 2em;
}

.form-button-frame {
  padding: 2em 2em 0;
  display: flex;
  justify-content: right;
  align-items: center;
}
#radio {
  display: flex;
  justify-content: center;
  margin-bottom: 1em;
}
#guide_radio {
  margin-left: 2em;
}
</style>
