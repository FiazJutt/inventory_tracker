import 'package:inventory_tracker/data/local/daos/container_dao.dart';
import 'package:inventory_tracker/data/local/daos/item_dao.dart';
import 'package:inventory_tracker/data/local/daos/location_dao.dart';
import 'package:inventory_tracker/data/local/daos/room_dao.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:inventory_tracker/models/item_model.dart';
import 'package:inventory_tracker/models/location_model.dart';
import 'package:inventory_tracker/models/room_model.dart';

/// Repository that coordinates access to the SQLite DAOs and converts
/// raw database maps into strongly typed models.
class InventoryRepository {
  InventoryRepository({
    LocationDao? locationDao,
    RoomDao? roomDao,
    ContainerDao? containerDao,
    ItemDao? itemDao,
  }) : _locationDao = locationDao ?? LocationDao(),
       _roomDao = roomDao ?? RoomDao(),
       _containerDao = containerDao ?? ContainerDao(),
       _itemDao = itemDao ?? ItemDao();

  final LocationDao _locationDao;
  final RoomDao _roomDao;
  final ContainerDao _containerDao;
  final ItemDao _itemDao;

  // ==================== LOCATIONS ====================

  Future<List<LocationModel>> fetchLocations() async {
    final rows = await _locationDao.getAll();
    return rows.map(LocationModel.fromDbMap).toList();
  }

  Future<void> upsertLocation(LocationModel location) async {
    await _locationDao.insert(location.toDbMap());
  }

  Future<void> deleteLocationByName(String name) async {
    await _locationDao.deleteByName(name);
  }

  Future<bool> locationExists(String name) async {
    return _locationDao.exists(name);
  }

  Future<List<LocationModel>> searchLocations(String query) async {
    final rows = await _locationDao.search(query);
    return rows.map(LocationModel.fromDbMap).toList();
  }

  // ==================== ROOMS ====================

  Future<List<Room>> fetchRooms() async {
    final rows = await _roomDao.getAll();
    return rows.map(Room.fromDbMap).toList();
  }

  Future<void> upsertRoom(Room room) async {
    await _roomDao.insert(room.toDbMap());
  }

  Future<void> deleteRoom(String id) async {
    await _roomDao.delete(id);
  }

  Future<List<Room>> searchRooms(String query) async {
    final rows = await _roomDao.search(query);
    return rows.map(Room.fromDbMap).toList();
  }

  // ==================== CONTAINERS ====================

  Future<List<ContainerModel>> fetchContainers() async {
    final rows = await _containerDao.getAll();
    return rows.map(ContainerModel.fromDbMap).toList();
  }

  Future<void> upsertContainer(ContainerModel container) async {
    await _containerDao.insert(container.toDbMap());
  }

  Future<void> updateContainer(ContainerModel container) async {
    await _containerDao.update(container.toDbMap());
  }

  Future<void> deleteContainer(String id) async {
    await _containerDao.delete(id);
  }

  Future<List<ContainerModel>> searchContainers(String query) async {
    final rows = await _containerDao.search(query);
    return rows.map(ContainerModel.fromDbMap).toList();
  }

  Future<ContainerModel?> getContainerById(String id) async {
    final row = await _containerDao.getById(id);
    if (row == null) return null;
    return ContainerModel.fromDbMap(row);
  }

  // ==================== ITEMS ====================

  Future<List<Item>> fetchItems() async {
    final rows = await _itemDao.getAll();
    return rows.map(Item.fromDbMap).toList();
  }

  Future<void> upsertItem(Item item) async {
    await _itemDao.insert(item.toDbMap());
  }

  Future<void> updateItem(Item item) async {
    await _itemDao.update(item.toDbMap());
  }

  Future<void> deleteItem(String id) async {
    await _itemDao.delete(id);
  }

  Future<List<Item>> searchItems(String query) async {
    final rows = await _itemDao.search(query);
    return rows.map(Item.fromDbMap).toList();
  }

  Future<Item?> getItemById(String id) async {
    final row = await _itemDao.getById(id);
    if (row == null) return null;
    return Item.fromDbMap(row);
  }

  Future<void> moveItem({
    required String itemId,
    required String newRoomId,
    String? newContainerId,
  }) async {
    await _itemDao.moveItem(
      itemId: itemId,
      newRoomId: newRoomId,
      newContainerId: newContainerId,
    );
  }
}
