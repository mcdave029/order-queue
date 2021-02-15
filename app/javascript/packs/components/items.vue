<template>
  <v-app>
    <v-data-table
      :headers="headers"
      :items="items"
      sort-by="name"
      :options.sync="options"
      :loading="loading"
      :server-items-length="totalItems"
      class="elevation-1"
    >
      <template v-slot:top>
        <v-toolbar
          flat
        >
          <v-toolbar-title>Orders Queue</v-toolbar-title>
          <v-divider
            class="mx-4"
            inset
            vertical
          ></v-divider>
          <v-spacer></v-spacer>
          <v-dialog
            v-model="dialog"
            max-width="500px"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-btn
                color="primary"
                dark
                class="mb-2"
                v-bind="attrs"
                v-on="on"
              >
                New Item
              </v-btn>
            </template>
            <v-card>
              <v-card-title>
                <span class="headline">{{ formTitle }}</span>
              </v-card-title>
  
              <v-card-text>
                <v-container>
                  <v-row>
                    <v-col
                      cols="12"
                      sm="6"
                      md="4"
                    >
                      <v-text-field
                        v-model="editedItem.name"
                        label="Name"
                        required
                      ></v-text-field>
                    </v-col>
                    <v-col
                      cols="12"
                      sm="6"
                      md="4"
                    >
                      <v-text-field
                        v-model="editedItem.quantity"
                        label="Quantity"
                        required
                      ></v-text-field>
                    </v-col>
                    <v-col
                      cols="12"
                      sm="6"
                      md="4"
                    >
                      <v-select
                        v-model="editedItem.status"
                        :items="statuses"
                        label="Status"
                        data-vv-name="select"
                        required
                      ></v-select>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
  
              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  color="blue darken-1"
                  text
                  @click="close"
                >
                  Cancel
                </v-btn>
                <v-btn
                  color="blue darken-1"
                  text
                  @click="save"
                >
                  Save
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>

          <v-dialog v-model="dialogDelete" max-width="500px">
            <v-card>
              <v-card-title class="headline">Are you sure you want to delete this item?</v-card-title>
              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="blue darken-1" text @click="closeDelete">Cancel</v-btn>
                <v-btn color="blue darken-1" text @click="deleteItemConfirm">OK</v-btn>
                <v-spacer></v-spacer>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </v-toolbar>
      </template>
      <template v-slot:item.actions="{ item }">
        <v-icon
          small
          class="mr-2"
          @click="editItem(item)"
        >
          mdi-pencil
        </v-icon>
        <v-icon
          small
          @click="deleteItem(item)"
        >
          mdi-delete
        </v-icon>
      </template>
      <template v-slot:no-data>
        <v-btn
          color="primary"
          @click="initialize"
        >
          Reset
        </v-btn>
      </template>
      <template v-slot:item.created_at="{ item }">
        <span>{{ new Date(item.created_at).toLocaleString() }}</span>
      </template>
    </v-data-table>
  </v-app>
</template>

<script>
import axios from "axios";

export default {
  data: () => ({
    dialog: false,
    dialogDelete: false,
    loading: true,
    totalItems: 0,
    options: {},
    headers: [
      { text: 'Name', value: 'name' },
      { text: 'Quantity', value: 'quantity' },
      { text: 'Status', value: 'status' },
      { text: 'Created At', value: 'created_at'},
      { text: 'Actions', value: 'actions', sortable: false }
    ],
    items: [],
    statuses: ["To Pack", "On Going", "Packed"],
    editedIndex: -1,
    editedItem: {
      name: '',
      quantity: 0,
      status: "To Pack"
    },
    defaultItem: {
      name: '',
      quantity: 0,
      status: "To Pack"
    },
  }),

  computed: {
    formTitle () {
      return this.editedIndex === -1 ? 'New Item' : 'Edit Item'
    }
  },

  watch: {
    dialog (val) {
      val || this.close()
    },
    dialogDelete (val) {
      val || this.closeDelete()
    },
    options: {
      handler () {
        this.initialize();
      },
      deep: true
    }
  },

  created () {
    this.initialize()
  },

  methods: {
    initialize () {
      this.loading = true;
      const { sortBy, sortDesc, page, itemsPerPage } = this.options;
      console.log(page);
      console.log(itemsPerPage);
      return axios
        .get("/items", {
          params: {
            sort_by: sortBy,
            sort_desc: sortDesc,
            per_page: itemsPerPage,
            page: page
          }
        })
        .then(response => {
          this.items = response.data.items;
          this.totalItems = response.data.total_count;
          this.loading = false;
        })
        .catch(e => {
          console.log(e);
        });
    },

    editItem (item) {
      this.editedIndex = this.items.indexOf(item)
      this.editedItem = Object.assign({}, item)
      this.dialog = true
    },

    deleteItem (item) {
      this.editedIndex = this.items.indexOf(item)
      this.editedItem = Object.assign({}, item)
      this.dialogDelete = true
    },

    deleteItemConfirm () {
      axios
          .delete(`/items/${this.editedItem.id}`)
          .then(response => {
            console.log(response);
          })
          .catch(error => {
            console.log(error);
          });
      this.items.splice(this.editedIndex, 1)
      this.closeDelete()
    },

    close () {
      this.dialog = false
      this.$nextTick(() => {
        this.editedItem = Object.assign({}, this.defaultItem)
        this.editedIndex = -1
      })
    },

    closeDelete () {
      this.dialogDelete = false
      this.$nextTick(() => {
        this.editedItem = Object.assign({}, this.defaultItem)
        this.editedIndex = -1
      })
    },

    save () {
      if (this.editedIndex > -1) {
        axios
          .put(`/items/${this.editedItem.id}`, {
            item: {
              name: this.editedItem.name,
              quantity: this.editedItem.quantity,
              status: this.editedItem.status
            }
          })
          .then(response => {
            Object.assign(this.items[this.editedIndex], response.data);
            this.close();
          })
          .catch(error => {
            console.log(error);
            this.close();
          });
      } else {
        axios
          .post(`/items`, {
            item: {
              name: this.editedItem.name,
              quantity: this.editedItem.quantity,
              status: this.editedItem.status
            }
          })
          .then(response => {
            this.items.push(response.data);
            this.close();
          })
          .catch(error => {
            console.log(error);
            this.close();
          });
      }
    },
  },
}; 
</script>
