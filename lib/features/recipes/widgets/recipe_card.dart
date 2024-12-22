// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, 
  required this.recipe_name, 
  required this.image_url, 
  required this.recipe_time});

  final String recipe_name;
  final String image_url;
  final String recipe_time;
  @override
  Widget build(BuildContext context) {
    
    return LayoutBuilder(
        builder: (context,constraints){
          double dynamicPadding = constraints.maxWidth * 0.05;
          
          
          return Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          alignment: Alignment.center,
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image_url),
              fit: BoxFit.cover,
              ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child:Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                 // Semi-transparent overlay
                ),
              ),
              
              Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(dynamicPadding),
                        child: SizedBox(
                          width: 200,
                          child: Text(recipe_name,
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        )
                                    ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top:60, left: 20, right: 20),  
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  Icon(Icons.access_alarm,                          
                                  color: Colors.deepOrange,),
                                  SizedBox(width: 5,),
                                  Text(recipe_time,
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  ),
                                  )
                              ],
                              )
                              ),
                              SizedBox(
                                child: Text('Giraneza'),
                              )
                          ],
                        ),
                      ),
                    )
                    ],
                    
                  ),
                ],
              ),
            ],
          ),         
          );
        }, 
    );
  }
}