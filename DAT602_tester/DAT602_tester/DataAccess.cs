using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using MySql.Data.MySqlClient;

namespace DAT602_tester
{
    class DataAccess
    {
        private static string connectionString
        {
            get { return "Server=localhost;Port=3306;Database=WarlockGame;Uid=warlock;password=12345;"; }

        }

        private static MySqlConnection _mySqlConnection = null;
        public static MySqlConnection mySqlConnection
        {
            get
            {
                if (_mySqlConnection == null)
                {
                    _mySqlConnection = new MySqlConnection(connectionString);
                }

                return _mySqlConnection;

            }
        }

        public string Register(string pUsername, string pPassword, string pEmail) 
        {
            List<MySqlParameter> p = new List<MySqlParameter>();

            var nameP = new MySqlParameter("@Username", MySqlDbType.VarChar, 50);
            nameP.Value = pUsername;
            p.Add(nameP);

            var passwordP = new MySqlParameter("@Password", MySqlDbType.VarChar, 50);
            passwordP.Value = pPassword;
            p.Add(passwordP);

            var emailP = new MySqlParameter("@Email", MySqlDbType.VarChar, 50);
            emailP.Value = pEmail;
            p.Add(emailP);

            var aDataSet = MySqlHelper.ExecuteDataset(DataAccess.mySqlConnection, " call Register(@Username, @Password, @Email)", p.ToArray());

            return aDataSet.ToString();

        }
        public string CreateCharacter(string pUsername, string pCharacterType, string pColor, int pMagic, int pStrength, int pTileID)
        {
            List<MySqlParameter> p = new List<MySqlParameter>();

            //making username parameter and giving it a value
             var nameP = new MySqlParameter("@Username", MySqlDbType.VarChar, 50);
             nameP.Value = pUsername;
             p.Add(nameP);

            //making character type parameter
            var characterTypeP = new MySqlParameter("@CharacterType", MySqlDbType.VarChar, 50);
            characterTypeP.Value = pCharacterType;
            p.Add(characterTypeP);

            var colorP = new MySqlParameter("@Color", MySqlDbType.VarChar, 50);
            colorP.Value = pColor;
            p.Add(colorP);

            var magicP = new MySqlParameter("@Magic", MySqlDbType.Int32);
            magicP.Value = pMagic;
            p.Add(magicP);

            var strengthP = new MySqlParameter("@Strength", MySqlDbType.Int32);
            strengthP.Value = pStrength;
            p.Add(strengthP);

            var tileIDP = new MySqlParameter("@TileID", MySqlDbType.Int32);
            tileIDP.Value = pTileID;
            p.Add(tileIDP);

            var aDataSet = MySqlHelper.ExecuteDataset(DataAccess.mySqlConnection, " call CreateCharacter(@Username, @CharacterType, @Color, @Magic, @Strength, @TileID)", p.ToArray());

            // expecting one table with one row
            return (aDataSet.Tables[0].Rows[0])["MESSAGE"].ToString();
        }



     
        public List<Player> GetAllPlayers()
        {
            List<Player> lcPlayers = new List<Player>();

            var aDataSet = MySqlHelper.ExecuteDataset(DataAccess.mySqlConnection, "call GetAllPlayers()");
            lcPlayers = (from aResult in
                                    System.Data.DataTableExtensions.AsEnumerable(aDataSet.Tables[0])
                         select
                            new Player
                            {
                                UserName = aResult["UserName"].ToString(),
                                //Strength = Convert.ToInt32(aResult["Strength"]),
                                //X = Convert.ToInt32(aResult["x"]),
                                //Y = Convert.ToInt32(aResult["y"])
                            }).ToList();
            return lcPlayers;
        }


    }
}
