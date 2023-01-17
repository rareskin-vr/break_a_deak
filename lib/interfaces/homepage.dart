import 'dart:convert';
import 'package:break_a_deak/config/configuration.dart';
import 'package:break_a_deak/data_model/product_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String categoryValue = "All";
  Map<String, Product> productAdded = {};
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse(Configuration.apiRootPath));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var list = data.map<Product>((json) => Product.fromJson(json)).toList();
      return list;
    } else {
      return ['No products available'];
    }
  }

  void _showDialog() {
    String json = jsonEncode(productAdded);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Buy now:"),
          content: SingleChildScrollView(
            child:
                Text(json.compareTo("{}") == 0 ? "Please add a product" : json),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget createProductTile(Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.27,
              child:
                  Image.asset("assets/images/${product.p_id.toString()}.png")),
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 8.0, left: 3, right: 3, bottom: 3),
              child: Text(
                product.p_name,
                style: const TextStyle(
                    letterSpacing: 1,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                product.p_category,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                product.p_details,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text("\u{20B9}${product.p_cost.toString()}",
                  style: const TextStyle(
                      letterSpacing: 1,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text("Stock: ${product.p_availability}")],
              ),
            ),
            StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Buy now: ",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(
                      width: 60,
                    ),
                    SizedBox(
                      height: 30,
                      width: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (product.quantity > 0) {
                              --product.quantity;
                              if (product.quantity == 0) {
                                productAdded.remove(product.p_id.toString());
                              }
                            }
                          });
                        },
                        child: const Text(
                          "-",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: Text(
                            product.quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (product.quantity < product.p_availability) {
                              product.quantity++;
                              productAdded.update(
                                  product.p_id.toString(), (data) => product,
                                  ifAbsent: () => product);
                            }
                          });
                        },
                        child: const Text(
                          "+",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Menu:"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              onPressed: () {
                _showDialog();
              },
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data is List<Product>) {
              final Map<String, List<Product>> categoryModel = {};
              categoryModel.update(
                  "All", (value) => snapshot.data! as List<Product>,
                  ifAbsent: () => snapshot.data! as List<Product>);
              for (int index = 0; index < snapshot.data!.length; index++) {
                categoryModel.update(snapshot.data![index].p_category,
                    (data) => data..add(snapshot.data![index]),
                    ifAbsent: () => [snapshot.data![index]]);
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Category :",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: DropdownButton<String>(
                          value: categoryValue,
                          items: categoryModel.keys.map((String key) {
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(key),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              categoryValue = newValue ?? "All";
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: categoryModel[categoryValue]!.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              createProductTile(
                                  categoryModel[categoryValue]![index]),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  color: Colors.grey.withOpacity(0.3),
                                  height: 1,
                                  thickness: 1,
                                ),
                              )
                            ],
                          );
                        }),
                  ),
                ],
              );
            } else if (snapshot.hasData && snapshot.data is! List<Product>) {
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 35,
                        color: Colors.blueGrey,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.data!.first,
                          style: const TextStyle(letterSpacing: 1),
                        ),
                      ),
                    ]),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
