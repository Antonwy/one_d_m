import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_d_m/helper/helper.dart';
import '../donation_unit.dart';

class BaseCampaign {
  final DateTime createdAt;
  final int amount, categoryId, maxAnimCount;
  final String name,
      description,
      shortDescription,
      dvAnimation,
      authorId,
      id,
      imgUrl,
      thumbnailUrl,
      adminId,
      shortVideoUrl,
      longVideoUrl,
      blurHash;
  final List<String> moreImages, donationEffects, effects, tags;
  final DonationUnit unit;

  static final String ID = "id",
      NAME = "title",
      DESCRIPTION = "description",
      SHORTDESCRIPTION = "short_description",
      CITY = "city",
      CREATEDAT = "created_at",
      AUTHORID = "author_id",
      ADMINID = "admin_id",
      AMOUNT = "amount",
      IMAGEURL = "image_url",
      MOREIMAGES = "more_image_urls",
      DONATIONIMAGES = "donation_images",
      THUMBNAILURL = "thumbnail_url",
      EFFECTS = "campaign_effects",
      DONATION_EFFECTS = "donation_effects",
      FINALAMOUNT = "target_amount",
      CATEGORYID = "category_id",
      SHORTVIDEOURL = "short_video_url",
      LONGVIDEOURL = "long_video_url",
      TAGS = "tags",
      DV_ANIMATION = "animation_url",
      MAX_ANIM_COUNT = "max_anim_count",
      DV_CONTROLLER = "dv_controller",
      UNIT = "unit",
      BLUR_HASH = "blur_hash";

  BaseCampaign(
      {this.id,
      this.name,
      this.description,
      this.shortDescription,
      this.createdAt,
      this.authorId,
      this.adminId,
      this.amount,
      this.imgUrl,
      this.moreImages,
      this.dvAnimation,
      this.thumbnailUrl,
      this.maxAnimCount = 3,
      this.categoryId,
      this.shortVideoUrl,
      this.longVideoUrl,
      this.donationEffects = const [],
      this.effects = const [],
      this.tags = const [],
      this.unit,
      this.blurHash});

  static BaseCampaign fromSnapshot(DocumentSnapshot snapshot) =>
      BaseCampaign.fromJson(snapshot.data());

  BaseCampaign.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        adminId = map[ADMINID],
        authorId = map[AUTHORID],
        blurHash = map[BLUR_HASH],
        categoryId = map[CATEGORYID],
        createdAt = DateTime.tryParse(map[CREATEDAT]),
        description = map[DESCRIPTION],
        imgUrl = map[IMAGEURL],
        longVideoUrl = map[LONGVIDEOURL],
        shortDescription = map[SHORTDESCRIPTION],
        shortVideoUrl = map[SHORTVIDEOURL],
        thumbnailUrl = map[THUMBNAILURL],
        name = map[NAME],
        unit = DonationUnit.fromMap(map),
        amount = map[AMOUNT],
        maxAnimCount = 3,
        dvAnimation = map[DV_ANIMATION],
        moreImages = [],
        effects = Helper.castList<String>(map[EFFECTS]),
        donationEffects = Helper.castList<String>(map[DONATION_EFFECTS]),
        tags = Helper.castList<String>(map[TAGS]);

  static List<BaseCampaign> listFromJson(List<Map<String, dynamic>> list) {
    return list.map((map) => BaseCampaign.fromJson(map)).toList();
  }

  static List<BaseCampaign> listFromSnapshot(List<DocumentSnapshot> list) {
    return list.map(BaseCampaign.fromSnapshot).toList();
  }

  @override
  bool operator ==(other) {
    if (other is BaseCampaign) return other.id == this.id;
    return false;
  }
}
