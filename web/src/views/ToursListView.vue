<template>
  <div id="tours-list-page">
    <p id="admin_show_name">
      {{
        $t("pages.tours.welcome_message", {
          admin_name: adminNameShow.name,
        })
      }}
    </p>
    <br />
    <h1>{{ $t("pages.tours.title") }}</h1>

    <!-- テーブル上部のボタン -->
    <div class="button-frame">
      <button class="button-orange" @click="tourcsv()">
        ツアー一覧CSVダウンロード
      </button>
      <button class="button-orange" @click="guidecsv()">
        ガイド一覧CSVダウンロード
      </button>
      <button @click="$router.push('/tours/create')" class="button-green">
        {{ $t("button.tour_create") }}
      </button>
      <button type="checkbox" class="button-green" @click="disp_open()">
        {{ $t("button.searchbar") }}
      </button>
    </div>

    <!-- 詳細検索 -->
    <div class="search-form-frame" v-if="isChecking === true">
      <h3>{{ $t("pages.tours.title_search") }}</h3>
      <form @submit.prevent="search" class="form-main">
        <div class="form-tabel">
          <!--ツアー名-->
          <span class="search-box">
            <label>{{ $t("label.tour_name") }}</label
            ><input type="text" id="tour_name" value="" />
          </span>

          <!--開始日-->
          <div class="search-box">
            <label>{{ $t("label.start_date") }}</label
            ><input type="date" id="start_datetime" />
            <label> {{ $t("label.time_to") }} </label
            ><input type="date" id="end_datetime" />
          </div>

          <!-- ツアー状態 --->
          <div class="search-box" id="search-from-state">
            <input type="checkbox" id="state1" value="1" checked />
            <label for="state1">{{ $t("state.tour.1") }}</label>
            <input type="checkbox" id="state2" value="2" checked />
            <label for="state2">{{ $t("state.tour.2") }}</label>
            <input type="checkbox" id="state32" value="32" checked />
            <label for="state32">{{ $t("state.tour.32") }}</label>
            <input type="checkbox" id="state256" value="256" /><label
              for="state256"
              >{{ $t("state.tour.256") }}</label
            >
          </div>
        </div>

        <!-- 検索ボタン -->
        <div class="form-button-frame">
          <button type="submit" class="button-green">
            {{ $t("button.search") }}
          </button>
        </div>
      </form>
    </div>

    <!-- 一覧テーブル -->
    <ToursTable :tours="tours"></ToursTable>
  </div>
</template>

<script>
import api from "@/mixins/api";
import table from "@/mixins/table";
import ToursTable from "@/components/ToursTable.vue";

export default {
  components: {
    ToursTable,
  },
  data() {
    return {
      tours: [],
      adminNameShow: {},
      isChecking: false,
      text: "",
    };
  },
  computed: {},
  methods: {
    async disp_open() {
      this.isChecking = !this.isChecking;
      if (this.isChecking) {
        localStorage.setItem("searchOpen", "1");
      } else {
        localStorage.setItem("searchOpen", "");
      }
    },

    async tourcsv() {
      // alert("tourcsv");
      this.text = "";
      // データを取得
      const url = `/api/v1/tours`;

      const request = {
        // word: document.getElementById("tour_name").value,
        tourcsv: "1",
      };

      // 送信
      const response = await api.get(url, request, this.$router.push);
      // ヘッダー
      this.text =
        "ID,ツアー名,開始日時,終了日時,状態,大人人数,子供人数,ガイド人数,参加可否入力制限,ガイドへの連絡事項,リマインドメールを送信する,担当ガイドID\n";
      this.text += response.data.map((e1) => e1.join(",")).join("\n");

      // this.text = response.data;
      // this.text = tours.map((e1) => e1.join(",")).join("\n");
      // this.text = tours;

      const bom = new Uint8Array([0xef, 0xbb, 0xbf]); // 変更 先頭の3バイト（BOM）を変数 bom へ代入
      // const url = URL.createObjectURL(new Blob([bom, this.text], {type: 'text/csv'})); // 変更 データの先頭に bom を配置
      const blob = new Blob([bom, this.text], { type: "text/csv" });
      // const blob = new Blob([this.text], { type: "text/plain" });
      const blobURL = window.URL.createObjectURL(blob);
      const obj = document.createElement("a");
      obj.href = blobURL;
      const d = new Date();

      const year = d.getFullYear();
      const month = d.getMonth() + 1;
      const day = d.getDate();
      const hour = d.getHours();
      const minute = d.getMinutes();
      const second = d.getSeconds();
      obj.download = `${`${year}${month}${day}${hour}${minute}${second}`}_tour.csv`;
      document.body.appendChild(obj);
      obj.click();
      obj.parentNode.removeChild(obj);
    },

    async guidecsv() {
      // alert("guidecsv");
      this.text = "";
      // データを取得
      const url = `/api/v1/tours`;

      const request = {
        // word: document.getElementById("tour_name").value,
        guidecsv: "1",
      };

      // 送信
      const response = await api.get(url, request, this.$router.push);
      // ヘッダー
      this.text =
        "ID,名前,メールアドレス,TEL,住所(市区町村),住所(それ以降),登録年,メモ,ガイド回数\n";
      this.text += response.data.map((e1) => e1.join(",")).join("\n");

      // this.text = response.data;
      // this.text = tours.map((e1) => e1.join(",")).join("\n");
      // this.text = tours;

      const bom = new Uint8Array([0xef, 0xbb, 0xbf]); // 変更 先頭の3バイト（BOM）を変数 bom へ代入
      // const url = URL.createObjectURL(new Blob([bom, this.text], {type: 'text/csv'})); // 変更 データの先頭に bom を配置
      const blob = new Blob([bom, this.text], { type: "text/csv" });
      // const blob = new Blob([this.text], { type: "text/plain" });
      const blobURL = window.URL.createObjectURL(blob);
      const obj = document.createElement("a");
      obj.href = blobURL;
      const d = new Date();

      const year = d.getFullYear();
      const month = d.getMonth() + 1;
      const day = d.getDate();
      const hour = d.getHours();
      const minute = d.getMinutes();
      const second = d.getSeconds();
      obj.download = `${`${year}${month}${day}${hour}${minute}${second}`}_guide.csv`;
      document.body.appendChild(obj);
      obj.click();
      obj.parentNode.removeChild(obj);
      // this.$router.push("/guidecsv");
    },

    async search() {
      // alert("search");
      const url = `/api/v1/tours`;
      // 検索用
      const statelist = [];
      // ローカルストレージ初期化
      localStorage.setItem("tour_name", "");
      localStorage.setItem("start_datetime", "");
      localStorage.setItem("end_datetime", "");
      localStorage.setItem("state1", "");
      localStorage.setItem("state2", "");
      localStorage.setItem("state32", "");
      localStorage.setItem("state256", "");
      localStorage.setItem("search", "1");
      // localStorage.setItem("searchOpen", "1");

      const request = {
        word: document.getElementById("tour_name").value,
      };

      localStorage.setItem(
        "tour_name",
        document.getElementById("tour_name").value
      );
      // 開始月日
      if (document.getElementById("start_datetime").value !== "") {
        request.start_date = document.getElementById("start_datetime").value;
        localStorage.setItem(
          "start_datetime",
          document.getElementById("start_datetime").value
        );
      }
      // 終了月日
      if (document.getElementById("end_datetime").value !== "") {
        request.end_date = document.getElementById("end_datetime").value;
        localStorage.setItem(
          "end_datetime",
          document.getElementById("end_datetime").value
        );
      }

      if (document.getElementById("state1").checked) {
        statelist.push(1);
        localStorage.setItem("state1", "1");
      }
      if (document.getElementById("state2").checked) {
        statelist.push(2);
        localStorage.setItem("state2", "1");
      }
      if (document.getElementById("state32").checked) {
        statelist.push(32);
        localStorage.setItem("state32", "1");
      }
      if (document.getElementById("state256").checked) {
        statelist.push(256);
        localStorage.setItem("state256", "1");
      }
      request.tour_state = statelist;

      // 送信
      const response = await api.get(url, request, this.$router.push);

      const tours = response.data;

      // 並び替え
      table.methods.sortBy(null, tours);

      this.tours = tours;
    },
  },
  created() {
    this.$emit("SendLoadComplete", true); // ロード完了をアニメーションに伝える
    this.text = this.csvData.map((e1) => e1.join(",")).join("\n");
  },
  mounted() {
    // この時点で初めてDOMにアクセスできます。
  },
  updated() {
    // alert("updated");

    // getメソッド
    if (localStorage.getItem("search") === "1") {
      // alert("search");
      // データが変更され、DOMが再描画された後に実行されます。
      // alert("updated");
      // alert(`get2 tour_name${localStorage.getItem("tour_name")}`);
      document.getElementById("tour_name").value =
        localStorage.getItem("tour_name");

      // 開始月日
      document.getElementById("start_datetime").value =
        localStorage.getItem("start_datetime");

      // 終了月日
      document.getElementById("end_datetime").value =
        localStorage.getItem("end_datetime");

      let element = document.getElementById("state1");
      element.checked = false;
      if (localStorage.getItem("state1")) {
        element.checked = true;
      }

      element = document.getElementById("state2");
      element.checked = false;
      if (localStorage.getItem("state2")) {
        element.checked = true;
      }

      element = document.getElementById("state32");
      element.checked = false;
      if (localStorage.getItem("state32")) {
        element.checked = true;
      }

      element = document.getElementById("state256");
      element.checked = false;
      if (localStorage.getItem("state256")) {
        element.checked = true;
      }
      localStorage.setItem("search", "");
    } /* else {
      // alert(`init`);
      // ローカルストレージ初期化
      localStorage.setItem("tour_name", "");
      localStorage.setItem("start_datetime", "");
      localStorage.setItem("end_datetime", "");
      localStorage.setItem("state1", "1");
      localStorage.setItem("state2", "1");
      localStorage.setItem("state32", "1");
      localStorage.setItem("state256", "");
      localStorage.setItem("search", "");
    } */
  },
  async beforeRouteEnter(to, from, next) {
    // alert("beforeRouteEnter");
    let isChecking = true;
    if (localStorage.getItem("searchOpen") !== "1") {
      isChecking = false;
    }

    if (localStorage.getItem("search") !== "1") {
      // alert("beforeRouteEnter_init");
      // ローカルストレージ初期化
      localStorage.setItem("tour_name", "");
      localStorage.setItem("start_datetime", "");
      localStorage.setItem("end_datetime", "");
      localStorage.setItem("state1", "1");
      localStorage.setItem("state2", "1");
      localStorage.setItem("state32", "1");
      localStorage.setItem("state256", "");
      localStorage.setItem("search", "");
      // isChecking = false;
    }
    const statelist = [];
    if (localStorage.getItem("state1")) {
      statelist.push(1);
    }
    if (localStorage.getItem("state2")) {
      statelist.push(2);
    }
    if (localStorage.getItem("state32")) {
      statelist.push(32);
    }
    if (localStorage.getItem("state256")) {
      statelist.push(256);
    }

    const request = {
      word: localStorage.getItem("tour_name"),
      tour_state: statelist,
    };

    if (localStorage.getItem("start_datetime") !== "") {
      request.start_date = localStorage.getItem("start_datetime");
    }

    if (localStorage.getItem("end_datetime") !== "") {
      request.end_date = localStorage.getItem("end_datetime");
    }

    // 並列で情報を取得
    await Promise.all([
      api.get("/api/v1/tours", request, next),
      api.get("/api/v1/admins/me", null, next),
    ]).then((result) => {
      // 情報を分解
      const tours = result[0].data;
      const { admin } = result[1].data;

      // ページへ渡す
      next((vm) => {
        vm.tours = tours;
        vm.adminNameShow = admin;
        vm.isChecking = isChecking;
      });
    });
  },
};
</script>

<style lang="scss" scoped>
@import "@/assets/css/table.scss";

#admin_show_name {
  font-size: 1.25em;
}

/* ------------ 検索バー関連 ------------ */

.button-frame {
  display: flex;
  flex-direction: row-reverse;
  margin: 1em;
}

.search-form-frame {
  display: block;
  background-color: var(--color-light-gray);
  border-radius: 0.5em;
  margin-bottom: 1em;
  padding: 0.5em 2em 1em;
}

.form-tabel {
  display: inline-block;
}

.form-button-frame {
  display: flex;
  flex-direction: row-reverse;
}

.search-box {
  padding: 0.5em;
}

#search-from-state > input {
  padding: 0.5em;
  margin-left: 1em;
}

.form-main {
  padding-top: 1em;
}
</style>
