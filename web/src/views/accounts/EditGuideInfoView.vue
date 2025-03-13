<template>
  <div id="change-guideinfo-page">
    <p class="error-info" v-if="$route.query.status == '500'">
      {{ $t("pages.guides.edit_guideinfo.message_false") }}
    </p>
    <h1>{{ $t("pages.guides.edit_guideinfo.title") }}</h1>
    <div class="form-frame">
      <div class="form-main">
        <div class="form-tabel">
          <label>名前&emsp;<font color="red">※必須</font>：</label
          ><input
            type="text"
            placeholder="name"
            id="name"
            v-bind:value="guide.name"
            maxlength="50"
          />
          <label>メールアドレス&emsp;<font color="red">※必須</font>：</label
          ><input
            type="text"
            placeholder="email"
            id="email"
            v-bind:value="guide.email"
            maxlength="300"
          />
          <label>TEL：</label
          ><input
            type="text"
            placeholder="tel"
            id="tel"
            v-bind:value="guide.tel"
            maxlength="15"
          />
          <label>住所(市区町村)：</label
          ><input
            type="text"
            placeholder="address1"
            id="address1"
            v-bind:value="guide.address1"
            maxlength="100"
          />
          <label>住所(それ以降)：</label
          ><input
            type="text"
            placeholder="address2"
            id="address2"
            v-bind:value="guide.address2"
            maxlength="100"
          />
          <label>登録年：</label
          ><input
            type="number"
            placeholder="addyear"
            id="addyear"
            v-bind:value="guide.addyear"
          />

          <label>{{ $t("label.memo") }}</label
          ><textarea
            cols="30"
            rows="5"
            name="memo"
            id="memo"
            v-bind:value="guide.memo"
          >
          </textarea>
        </div>
        <br />
        <div class="form-button-frame">
          <button class="" @click="$router.back()">
            {{ $t("button.cancel") }}
          </button>
          <button type="submit" @click="edit()" class="button-green">
            {{ $t("button.change") }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "@/mixins/api";

export default {
  data() {
    return {
      is_invalid: false,
      guide: {},
    };
  },
  created() {
    this.$emit("SendLoadComplete", true); // ロード完了をアニメーションに伝える
  },
  methods: {
    async edit() {
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
      const object = {
        name: document.getElementById("name").value,
        email: document.getElementById("email").value,
        memo: document.getElementById("memo").value,
        tel: document.getElementById("tel").value,
        address1: document.getElementById("address1").value,
        address2: document.getElementById("address2").value,
        addyear: document.getElementById("addyear").value,
      };

      // ロード中にする
      this.$emit("SendLoadComplete", false);

      // アカウント作成情報を送信
      const response = await api.patch(
        `/api/v1/guides/${this.$route.params.id}`,
        object,
        this.$router.push
      );

      // API完了
      if (response.data.duplicates) {
        alert("メールアドレスが重複しています。削除済みも確認してください");
      } else if (response.status === "success") {
        // 成功
        alert(this.$t("pages.guides.edit_guideinfo.alert1"));
        const path = `/accounts/guides/${this.$route.params.id}`;
        this.$router.push(path);
      } else {
        // 失敗
        this.$router.push("?status=500").catch(() => {});
      }

      this.$emit("SendLoadComplete", true);
    },
  },
  async beforeRouteEnter(to, from, next) {
    const response = await api.get(
      `/api/v1/guides/${to.params.id}`,
      null,
      next
    );

    next((vm) => {
      vm.is_invalid = !(response.status === "success");
      vm.guide = response.data.guide;
    });
  },
};
</script>

<style scoped>
.change-guideinfo-page {
  max-width: 100%;
  position: relative;
}

.error-info {
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
</style>
