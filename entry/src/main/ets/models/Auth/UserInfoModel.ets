export class UserInfoModel {
  userId: string;
  phone: string;
  nickname: string;
  avatar: string;

  constructor(userId: string, phone: string, nickname: string = '', avatar: string = '') {
    this.userId = userId;
    this.phone = phone;
    this.nickname = nickname;
    this.avatar = avatar;
  }
}
