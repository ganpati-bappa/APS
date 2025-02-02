import 'package:aps/blocs/home_bloc/home_bloc.dart';
import 'package:aps/src/constants/images.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/styles.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:aps/src/screens/groups.dart';
import 'package:aps/src/screens/user_profile.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<StatefulWidget> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadingRequired());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      homePage(context),
      AllGroups(),
      const UserProfile()
    ];
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
          maintainBottomViewPadding: true,
          child: CircleNavBar(
            activeIcons: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.chat, color: Colors.white),
              Icon(Icons.face, color: Colors.white),
            ],
            inactiveIcons: const [
              Icon(Icons.home_outlined, color: Color.fromARGB(255, 254, 93, 104),),
              Icon(Icons.chat_outlined, color: Color.fromARGB(255, 254, 93, 104)),
              Icon(Icons.face_outlined, color: Color.fromARGB(255, 254, 93, 104)),
            ],
            color: const Color.fromARGB(255, 255, 200, 204),
            circleColor: const Color.fromARGB(255, 253, 120, 129),
            height: 55,
            circleWidth: 50,
            activeIndex: index,
            onTap: (value) {
              setState(() {
                index = value;
              });
            },
            tabDurationMillSec: 1000,
            iconDurationMillSec: 1000,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            cornerRadius: const BorderRadius.all(Radius.circular(30)),
            shadowColor: const Color.fromARGB(255, 253, 120, 129),
            elevation: 6,
          )),
    );
  }
}

Widget createCards(int index, int size) {
  return Transform.translate(
    offset: const Offset(defaultPadding - 2, 0),
    child: Row(
      children: [
        Container(
            margin: const EdgeInsets.only(right: 20, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: cardRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            width: 220,
            height: 320,
            padding:
                const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      cardImages[index],
                      width: 165,
                      height: 150,
                    ),
                    const SizedBox(
                      height: defaultColumnSpacingSm,
                    ),
                    Text(whyChooseUsCards[index]["heading"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: homePageKeyFeatureHeadingStyle),
                    Padding(
                      padding: const EdgeInsets.all(defaultColumnSpacingSm),
                      child: Text(
                        whyChooseUsCards[index]["text"],
                        style: homePageKeyFeatureSubheadingStyle,
                      ),
                    )
                  ]),
            )),
        lastWidget((index == size)),
      ],
    ),
  );
}

Widget lastWidget(bool isLastWidget) {
  if (isLastWidget) {
    return const SizedBox(width: 40);
  } else {
    return const SizedBox(
      width: 0,
    );
  }
}

Widget createCourseCard(int index, BuildContext context, int size) {
  return Transform.translate(
    offset: const Offset(defaultPadding - 2, 0),
    child: Row(
      children: [
        Container(
            margin: const EdgeInsets.only(right: 20, bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 4), // Position of the shadow
                  ),
                ]),
            height: 340,
            width: MediaQuery.of(context).size.width - 50,
            padding: const EdgeInsets.all(defaultPaddingMd),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPaddingXs,
                          horizontal: defaultPaddingSm),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 234, 246, 255),
                        borderRadius: BorderRadius.all(inputBorderRadius),
                      ),
                      child: Text(
                        courses[index]["duration"],
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 113, 191, 255),
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(courses[index]["heading"],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(courses[index]["text"],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(coursesPerWeek,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: 8,
                      width: 300,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index1) => getDaysPerWeek(
                              context, index1, courses[index]["classes"])),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    const Text(userReview,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      height: 20,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:5,
                        itemBuilder: (context, index2) {
                          if (index2 < courses[index]["review"]) {
                            return const Icon(Icons.star, color: Color.fromARGB(255, 253, 238, 97),);
                          } else {
                            return const Icon(Icons.star_outline, color: Colors.grey,);
                          }
                        },
                      )
                    )
                  ]),
            )),
        lastWidget(index == size),
      ],
    ),
  );
}

Widget getDaysPerWeek(BuildContext context, int index, int classes) {
  if (classes > index) {
    return Container(
      width: 30,
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 39, 52, 39)),
          borderRadius: sendButtonRadius),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: sendButtonRadius,
            color: const Color.fromARGB(255, 103, 255, 181)),
      ),
    );
  } else {
    return Container(
      width: 30,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.451)),
          borderRadius: sendButtonRadius),
    );
  }
}

Widget getPagesPerIndex(int index, BuildContext context) {
  switch (index) {
    case 0:
      return homePage(context);
    case 1:
      return Navigator(
        onGenerateRoute: (RouteSettings settings) =>
            MaterialPageRoute(builder: (newContext) => AllGroups()),
      );
    default:
      return const UserProfile();
  }
}

Widget homePage(context) {
  return SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    logo,
                    height: 70,
                    width: 70,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeTitle,
                        style: homePageHeadingStyle,
                      ),
                      Text(homeSubtitle, style: homePageSubheadingStyle),
                    ]),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child:
                    Text(homeSection1Title, style: homePageSectionHeadingStyle),
              ),
              const SizedBox(height: defaultColumnSpacingSm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(homeSection1Subtitle,
                    style: homePageSectionParagraphStyle),
              ),
              const SizedBox(
                height: defaultColumnSpacingMd,
              ),
              SizedBox(
                height: 350,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => createCards(index, 4)),
              )
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: defaultColumnSpacingMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text(homeSection2Title,
                      style: homePageSectionHeadingStyle),
                ),
                const SizedBox(height: defaultColumnSpacingMd),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text(homeSection2Subtitle,
                      style: homePageSectionParagraphStyle),
                ),
                const SizedBox(height: defaultColumnSpacingLg),
                SizedBox(
                  height: 350,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) =>
                          createCourseCard(index, context, 3)),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}
